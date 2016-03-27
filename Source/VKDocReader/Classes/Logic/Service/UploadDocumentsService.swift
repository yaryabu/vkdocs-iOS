//
//  UploadDocumentsService.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 23/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import Foundation
import SwiftyJSON

class UploadDocumentsService: Service {
    
    let authService: AuthService
    let userSettingsSerivce: UserSettingsSerivce
    
    init(authService: AuthService, userSettingsSerivce: UserSettingsSerivce) {
        self.authService = authService
        self.userSettingsSerivce = userSettingsSerivce
    }
    
    //FIXME: еще немого вложенных запросов и они перестанут помещаться на экран
    func uploadDocument(pathToFile: String, documentName: String, completion: () -> Void, progress: (totalUploaded: Int, bytesToUpload: Int) -> Void, failure: (error: Error) -> Void) {
        let token = ServiceLayer.sharedServiceLayer.authService.token!
        transport.getJSON(Const.Network.baseUrl + "/docs.getUploadServer", parameters: ["access_token":token], completion: { (json) -> Void in
            
            if let error = self.checkError(json) {
                Dispatch.mainQueue({ () -> () in
                    NSNotificationCenter.defaultCenter().postNotificationName(Const.Notifications.uploadComplete, object: nil)
                    failure(error: error)
                })
                return
            }
            
            self.loadTaskManager.uploadFile(self.parseServerUrlResponse(json), pathToFile: NSURL(fileURLWithPath: pathToFile), progressClosure: { (totalUploaded, totalToUpload) -> Void in
                Dispatch.mainQueue({ () -> () in
                    progress(totalUploaded: totalUploaded, bytesToUpload: totalToUpload)
                    let percent = Double(totalUploaded)/Double(totalToUpload)
                    NSNotificationCenter.defaultCenter().postNotificationName(Const.Notifications.uploadProgress, object: Float(percent))
                })
                }, completion: { (json) -> Void in
                    if let error = self.checkError(json) {
                        Dispatch.mainQueue({ () -> () in
                            NSNotificationCenter.defaultCenter().postNotificationName(Const.Notifications.uploadComplete, object: nil)
                            failure(error: error)
                        })
                        return
                    }
                    self.transport.getJSON(Const.Network.baseUrl + "/docs.save", parameters: self.saveParameters(documentName, vkFileParam: self.parseUploadResponse(json)), completion: { (json) -> Void in
                        if let error = self.checkError(json) {
                            Dispatch.mainQueue({ () -> () in
                                NSNotificationCenter.defaultCenter().postNotificationName(Const.Notifications.uploadComplete, object: nil)
                                failure(error: error)
                            })
                            return
                        }
                        Dispatch.mainQueue({ () -> () in
                            completion()
                            NSNotificationCenter.defaultCenter().postNotificationName(Const.Notifications.uploadComplete, object: nil)
                        })
                        }, failure: { (error) -> Void in
                            if let error = self.createError(error) {
                                NSNotificationCenter.defaultCenter().postNotificationName(Const.Notifications.uploadComplete, object: nil)
                                failure(error: error)
                            }
                    })
                }, failure: { (error) -> Void in
                    if let error = self.createError(error) {
                        NSNotificationCenter.defaultCenter().postNotificationName(Const.Notifications.uploadComplete, object: nil)

                        failure(error: error)
                    }
            })
            }) { (error) -> Void in
                if let error = self.createError(error) {
                    NSNotificationCenter.defaultCenter().postNotificationName(Const.Notifications.uploadComplete, object: nil)
                    failure(error: error)
                }
        }
    }
    
    func isUploadingNow() -> Bool {
        return LoadTaskManager.sharedManager.isUploadingNow
    }
    
    private func parseServerUrlResponse(json: JSON) -> String {
        let serverUrl = json["response"]["upload_url"].string!
        return serverUrl
    }
    
    private func parseUploadResponse(json: JSON) -> String {
        return json["file"].string!
    }
    
    private func saveParameters(fileName: String, vkFileParam: String) -> [String:String] {
        return [
            "access_token": ServiceLayer.sharedServiceLayer.authService.token!,
            "file":vkFileParam,
            "title":fileName
        ]
    }
}