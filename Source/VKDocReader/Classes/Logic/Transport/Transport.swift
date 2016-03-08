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

    var downloadRequestPool: [String:Request] = [:]

    func getJSON(urlString: String, parameters: [String:AnyObject]?, completion: (json: JSON) -> Void, failure: (error: NSError) -> Void) {
        self.request(.GET, urlString, parameters: parameters, encoding: .URL, headers: nil)
            .responseJSON { (response) -> Void in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    print("transport", value)
                    Dispatch.defaultQueue({ () -> () in
                        completion(json: json)
                    })
                }
            case .Failure(let error):
                Dispatch.defaultQueue({ () -> () in
                    failure(error: error)
                })
            }
        }
    }
    
    func getData(urlString: String, completion: (data: NSData) -> Void, failure: (error: NSError) -> Void) {
        self.request(.GET, urlString, parameters: nil, encoding: .URL, headers: nil)
            .progress({ (num1, num2, num3) -> Void in
//                let prog = Int((Double(num2)/Double(num3))*100)
//                print("prog \(prog)")
            })
            .responseData { (response) -> Void in
            switch response.result {
            case .Success:
                Dispatch.defaultQueue({ () -> () in
                    completion(data: response.data!)
                })
            case .Failure(let error):
                Dispatch.defaultQueue({ () -> () in
                    failure(error: error)
                })
            }
        }
    }
    
    func downloadFile(urlString: String, fileDirectory: String, fileExtension: String, progress: (totalReadBytes: UInt, bytesToRead: UInt) -> Void, completion: (fileName: String, filePath: String) -> Void, failure: (error: NSError) -> Void) {
        
        var downloadRequest: Request?
        
        if self.downloadRequestPool[urlString] != nil {
            downloadRequest = downloadRequestPool[urlString]
        } else {
            downloadRequest = self.download(.GET, urlString, destination: {(temporaryUrl, response) -> NSURL in
                let fileNamePath = self.computeFilePath(fileDirectory, fileExtension: fileExtension, suggestedFilename: response.suggestedFilename)
                return NSURL(fileURLWithPath: fileNamePath.filePath)
            })
            self.downloadRequestPool[urlString] = downloadRequest
        }
        
        downloadRequest!
            .progress({ (read, totalRead, size) -> Void in
                progress(totalReadBytes: UInt(totalRead), bytesToRead: UInt(size))
            })
            .response { (request, response, data, error) -> Void in
                print("eto ya")
                if (error != nil) {
                    failure(error: error!)
                    self.cancelFileDownload(urlString)
                } else {
                    let fileNamePath = self.computeFilePath(fileDirectory, fileExtension: fileExtension, suggestedFilename: response!.suggestedFilename)
                    completion(fileName: fileNamePath.fileName, filePath: fileNamePath.filePath)
                }
                self.downloadRequestPool.removeValueForKey(urlString)
            }
    }
    
    func cancelFileDownload(urlString: String) {
        if let request = self.downloadRequestPool[urlString] {
            request.cancel()
            self.downloadRequestPool.removeValueForKey(urlString)
        }
    }
    
    private func computeFilePath(fileDirectory: String, fileExtension: String, suggestedFilename: String?) -> (fileName: String, filePath: String) {
        if let name = suggestedFilename {
            let filePath = fileDirectory + "/" + name
            print(filePath)
            return (name, filePath)
        } else {
            let name = "no_name." + fileExtension
            let filePath = fileDirectory + "/" + name
            print(filePath)
            return (name, filePath)
        }
    }
}