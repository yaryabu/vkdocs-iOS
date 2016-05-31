//
//  LoadTaskManager.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 27/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import Foundation

import Alamofire
import SwiftyJSON

func += <KeyType, ValueType> (inout left: Dictionary<KeyType, ValueType>, right: Dictionary<KeyType, ValueType>) {
    for (k, v) in right {
        left.updateValue(v, forKey: k)
    }
}

/**
 Транспорт для загрузки и аплоада файлов. Вынесен в отдельный класс из-за использования в бэкграунде.
 */
class LoadTaskManager: Alamofire.Manager {
    static let sharedManager = LoadTaskManager()
    private static let backgroundSessionIdentifier = Const.Common.bundleIdentifier + "network.backgroundSession"
    
    var downloadRequestPool: [RequestPoolItem] = [] {
        didSet {
            debugLog(downloadRequestPool)
            
            if downloadRequestPool.count > 1 {
                downloadRequestPool[0].request.resume()
                downloadRequestPool[1].request.resume()
            } else if downloadRequestPool.count == 1 {
                downloadRequestPool[0].request.resume()
            }
        }
    }
    
    var isUploadingNow = false
    
    private init() {
        let config = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(LoadTaskManager.backgroundSessionIdentifier)
        
        config.HTTPAdditionalHeaders = Manager.defaultHTTPHeaders
        config.URLCache = NSURLCache.sharedURLCache()
        config.HTTPShouldSetCookies = false
        
        super.init(configuration: config)
        startRequestsImmediately = false
    }
    
    func requestForId(id: String) -> RequestPoolItem? {
        for req in downloadRequestPool {
            if req.docId == id {
                return req
            }
        }
        return nil
    }
    
    func removeRequestWithId(id: String) {
        for (i, req) in downloadRequestPool.enumerate() {
            if req.docId == id {
                req.request.cancel()
                downloadRequestPool.removeAtIndex(i)
                return
            }
        }
    }
    
    func downloadFile(urlString: String, fileDirectory: String, fileExtension: String, fileId: String, progress: (totalReadBytes: UInt, bytesToRead: UInt) -> Void, completion: (fileName: String, filePath: String) -> Void, failure: (error: NSError) -> Void) {
        
        var downloadRequest: RequestPoolItem!
        
        if let req = self.requestForId(fileId) {
            downloadRequest = req
        } else {
            let req = self.download(.GET, urlString, destination: {(temporaryUrl, response) -> NSURL in
                let fileNamePath = self.computeFilePath(fileDirectory, fileExtension: fileExtension, suggestedFilename: response.suggestedFilename)
                return NSURL(fileURLWithPath: fileNamePath.filePath)
            })
            
            downloadRequest = RequestPoolItem(request: req, docId: fileId)
            self.downloadRequestPool.append(downloadRequest)
        }
        
        downloadRequest.request
            .progress({ (read, totalRead, size) -> Void in
                if totalRead >= 0 && size >= 0 {
                    progress(totalReadBytes: UInt(totalRead), bytesToRead: UInt(size))
                }
            })
            .response { (request, response, data, error) -> Void in
                debugLog(downloadRequest.request)
                if (error != nil) {
                    failure(error: error!)
                    
                    self.cancelFileDownload(fileId)
                } else {
                    let fileNamePath = self.computeFilePath(fileDirectory, fileExtension: fileExtension, suggestedFilename: response!.suggestedFilename)
                    completion(fileName: fileNamePath.fileName, filePath: fileNamePath.filePath)
                    self.cancelFileDownload(fileId)
                }
                
        }
    }
    
    func uploadFile(serverUrl: String, pathToFile: NSURL, progressClosure: (totalUploaded: Int, totalToUpload: Int) -> Void, completion: (json: JSON) -> Void, failure: (error: NSError) -> Void) {
        
        upload(.POST, serverUrl, multipartFormData: { (multipart) -> Void in
            multipart.appendBodyPart(fileURL: pathToFile, name: "file")
        }) { (encodingResult) -> Void in
            switch encodingResult {
            case .Success(let upload, _, _):
                upload.resume()
                self.isUploadingNow = true
                upload
                    .progress({ (uploaded, totalUploaded, totalToUpload) -> Void in
                        progressClosure(totalUploaded: Int(totalUploaded), totalToUpload: Int(totalToUpload))
                    })
                    .responseJSON { (response) -> Void in
                        self.isUploadingNow = false
                        switch response.result {
                        case .Success:
                            if let value = response.result.value {
                                Dispatch.defaultQueue({ () -> () in
                                    let json = JSON(value)
                                    completion(json: json)
                                })
                            }
                        case .Failure(let error):
                            failure(error: error)
                        }
                }
            case .Failure:
                break
            }
            
        }
    }
    
    func requestForIdExists(id: String) -> Bool {
        for req in downloadRequestPool {
            if req.docId == id {
                return true
            }
        }
        return false
    }
    
    func cancelFileDownload(id: String) {
        for (i, item) in downloadRequestPool.enumerate() {
            if item.docId == id {
                item.request.cancel()
                downloadRequestPool.removeAtIndex(i)
                return
            }
        }
    }
    
    func cancelAllDownloads() {
        for item in downloadRequestPool {
            item.request.cancel()
        }
        downloadRequestPool.removeAll()
    }
    
    private func computeFilePath(fileDirectory: String, fileExtension: String, suggestedFilename: String?) -> (fileName: String, filePath: String) {
        if let name = suggestedFilename {
            let filePath = fileDirectory + "/" + name
            return (name, filePath)
        } else {
            let name = "no_name." + fileExtension
            let filePath = fileDirectory + "/" + name
            return (name, filePath)
        }
    }
}


struct RequestPoolItem {
    let request: Request
    let docId: String
}
