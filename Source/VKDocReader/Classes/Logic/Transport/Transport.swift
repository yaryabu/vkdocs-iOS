//
//  Transport.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 05/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import Alamofire
import SwiftyJSON

class Transport: Alamofire.Manager {
    static let sharedTransport = Transport()

    private init() {
        super.init()
    }

//    var downloadRequestPool: [String:Request] = [:]
    
//    init() {
////        let aaa = NSURLSessionConfiguration.defaultSessionConfiguration()
////        print("AAAAAA", aaa.timeoutIntervalForRequest, aaa.timeoutIntervalForResource)
//        let config = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("ouf'[ewuhfwae[huew[whe[hu[uhfhuoawfgouawu;")
////        config.timeoutIntervalForResource = 10
////        config.timeoutIntervalForRequest = 1
//        super.init(configuration: config, delegate: Manager.SessionDelegate(), serverTrustPolicyManager: nil)
//    }
    
    func getJSON(urlString: String, parameters: [String:AnyObject]?, completion: (json: JSON) -> Void, failure: (error: NSError) -> Void) {
        //TODO вынести добалвение параметра на уровень сервисов
        var newParams = parameters ?? [:]
        newParams["v"] = Const.Network.apiVersion
        self.request(.GET, urlString, parameters: newParams, encoding: .URL, headers: nil)
            .responseJSON { (response) -> Void in
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
    }
    
    func getData(urlString: String, completion: (data: NSData) -> Void, failure: (error: NSError) -> Void) {
        self.request(.GET, urlString, parameters: nil, encoding: .URL, headers: nil)
            .responseData { (response) -> Void in
            switch response.result {
            case .Success:
                Dispatch.defaultQueue({ () -> () in
                    completion(data: response.data!)
                })
            case .Failure(let error):
                failure(error: error)
            }
        }
    }
//    
//    func downloadFile(urlString: String, fileDirectory: String, fileExtension: String, progress: (totalReadBytes: UInt, bytesToRead: UInt) -> Void, completion: (fileName: String, filePath: String) -> Void, failure: (error: NSError) -> Void) {
//        
//        BackgroundManager.sharedManager.downloadFile(urlString, fileDirectory: fileDirectory, fileExtension: fileExtension, progress: progress, completion: completion, failure: failure)
//        return
//        
//        var downloadRequest: Request?
//
//        if self.downloadRequestPool[urlString] != nil {
//            downloadRequest = downloadRequestPool[urlString]
//        } else {
//            downloadRequest = self.download(.GET, urlString, destination: {(temporaryUrl, response) -> NSURL in
//                let fileNamePath = self.computeFilePath(fileDirectory, fileExtension: fileExtension, suggestedFilename: response.suggestedFilename)
//                return NSURL(fileURLWithPath: fileNamePath.filePath)
//            })
//            self.downloadRequestPool[urlString] = downloadRequest
//        }
//        
//        downloadRequest!
//            .progress({ (read, totalRead, size) -> Void in
//                progress(totalReadBytes: UInt(totalRead), bytesToRead: UInt(size))
//            })
//            .response { (request, response, data, error) -> Void in
//                if (error != nil) {
//                    failure(error: error!)
//                    self.cancelFileDownload(urlString)
//                } else {
//                    let fileNamePath = self.computeFilePath(fileDirectory, fileExtension: fileExtension, suggestedFilename: response!.suggestedFilename)
//                    completion(fileName: fileNamePath.fileName, filePath: fileNamePath.filePath)
//                }
//                self.downloadRequestPool.removeValueForKey(urlString)
//            }
//    }
//    
    //используется только в Share Extension
    func uploadFile(serverUrl: String, pathToFile: NSURL, progressClosure: (totalUploaded: Int, totalToUpload: Int) -> Void, completion: (json: JSON) -> Void, failure: (error: NSError) -> Void) {
        
        upload(.POST, serverUrl, multipartFormData: { (multipart) -> Void in
            multipart.appendBodyPart(fileURL: pathToFile, name: "file")
            }) { (encodingResult) -> Void in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload
                        .progress({ (uploaded, totalUploaded, totalToUpload) -> Void in
                            progressClosure(totalUploaded: Int(totalUploaded), totalToUpload: Int(totalToUpload))
                        })
                        .responseJSON { (response) -> Void in
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
//
//    func requestForUrlExists(urlString: String) -> Bool {
//        if self.downloadRequestPool[urlString] != nil {
//            return true
//        } else {
//            return false
//        }
//    }
//    
//    func cancelFileDownload(urlString: String) {
//        if let request = self.downloadRequestPool[urlString] {
//            request.cancel()
//            self.downloadRequestPool.removeValueForKey(urlString)
//        }
//    }
//    
//    func cancelAllDownloads() {
//        for request in self.downloadRequestPool {
//            request.1.cancel()
//        }
//        self.downloadRequestPool = [:]
//    }
//    
//    private func computeFilePath(fileDirectory: String, fileExtension: String, suggestedFilename: String?) -> (fileName: String, filePath: String) {
//        if let name = suggestedFilename {
//            let filePath = fileDirectory + "/" + name
//            print(filePath)
//            return (name, filePath)
//        } else {
//            let name = "no_name." + fileExtension
//            let filePath = fileDirectory + "/" + name
//            print(filePath)
//            return (name, filePath)
//        }
//    }
}

struct RequestPoolItem {
    let requestUrl: String
    let request: Request
    
    init(requestUrl: String, request: Request) {
        self.requestUrl = requestUrl
        self.request = request
    }
}

//TODO: В отдельный файл
class LoadTaskManager: Alamofire.Manager {
    static let sharedManager = LoadTaskManager()
    
    var downloadRequestPool: [Request] {
        didSet {
            print("COUNT", downloadRequestPool.count)
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
    
    private init() {
        downloadRequestPool = []
        let config = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("ouf'[ewuhfwae[huew[whe[hu[uhfhuoawfgouawu;")
        super.init(configuration: config, delegate: Manager.SessionDelegate(), serverTrustPolicyManager: nil)
//        delegate.taskWillPerformHTTPRedirection = nil
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
                upload
                    .progress({ (uploaded, totalUploaded, totalToUpload) -> Void in
                        progressClosure(totalUploaded: Int(totalUploaded), totalToUpload: Int(totalToUpload))
                    })
                    .responseJSON { (response) -> Void in
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