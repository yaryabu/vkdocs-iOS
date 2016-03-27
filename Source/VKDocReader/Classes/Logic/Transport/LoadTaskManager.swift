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


/**
 Транспорт для загрузки и аплоада файлов. Вынесен в отдельный класс из-за использования в бэкграунде.
 */
class LoadTaskManager: Alamofire.Manager {
    static let sharedManager = LoadTaskManager()
    
    var downloadRequestPool: [Request] {
        didSet {
            if downloadRequestPool.count > 1 {
                downloadRequestPool[0].resume()
                downloadRequestPool[1].resume()
                print("RESUME")
            } else if downloadRequestPool.count == 1 {
                print("RESUME 111")
                downloadRequestPool[0].resume()
            }
        }
    }
    
    var isUploadingNow = false
    
    private init() {
        downloadRequestPool = []
        let config = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("ouf'[ewuhfwae[huew[whe[hu[uhfhuoawfgouawu;")
        super.init(configuration: config, delegate: Manager.SessionDelegate(), serverTrustPolicyManager: nil)
        super.delegate.taskWillPerformHTTPRedirection = nil
        delegate.taskWillPerformHTTPRedirection = nil
        startRequestsImmediately = false
    }
    
    func requestForUrlString(urlString: String) -> Request? {
        for req in downloadRequestPool {
            if req.request!.URLString == urlString {
                return req
            }
        }
        return nil
    }
    
    func removeRequestWithUrlString(urlString: String) {
        for req in downloadRequestPool {
            if req.request!.URLString == urlString {
                
            }
        }
    }
    
    func downloadFile(urlString: String, fileDirectory: String, fileExtension: String, progress: (totalReadBytes: UInt, bytesToRead: UInt) -> Void, completion: (fileName: String, filePath: String) -> Void, failure: (error: NSError) -> Void) {
        
        var downloadRequest: Request!
        
        if let req = self.requestForUrlString(urlString) {
            downloadRequest = req
        } else {
            downloadRequest = self.download(.GET, urlString, destination: {(temporaryUrl, response) -> NSURL in
                let fileNamePath = self.computeFilePath(fileDirectory, fileExtension: fileExtension, suggestedFilename: response.suggestedFilename)
                return NSURL(fileURLWithPath: fileNamePath.filePath)
            })
            self.downloadRequestPool.append(downloadRequest)
            //            self.downloadRequestPool[urlString] = downloadRequest
        }
        
        downloadRequest!
            .progress({ (read, totalRead, size) -> Void in
                progress(totalReadBytes: UInt(totalRead), bytesToRead: UInt(size))
            })
            .response { (request, response, data, error) -> Void in
                if (error != nil) {
                    failure(error: error!)
                    print("ERROR", error)
                    
                    self.cancelFileDownload(urlString)
                    print("CANCEL FAIL", urlString)
                } else {
                    let fileNamePath = self.computeFilePath(fileDirectory, fileExtension: fileExtension, suggestedFilename: response!.suggestedFilename)
                    completion(fileName: fileNamePath.fileName, filePath: fileNamePath.filePath)
                    self.cancelFileDownload(urlString)
                    print("CANCEL OK", urlString)
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
    
    func requestForUrlExists(urlString: String) -> Bool {
        for req in downloadRequestPool {
            if req.request!.URLString == urlString {
                return true
            }
        }
        return false
    }
    
    func cancelFileDownload(urlString: String) {
        for (i, req) in downloadRequestPool.enumerate() {
            if req.request!.URLString == urlString {
                req.cancel()
                downloadRequestPool.removeAtIndex(i)
                return
            }
        }
    }
    
    func cancelAllDownloads() {
        for req in downloadRequestPool {
            req.cancel()
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
