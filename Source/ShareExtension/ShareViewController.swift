//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by Yaroslav Ryabukha on 14/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices

import KeychainAccess
import Foundation
import SwiftyJSON

class ShareViewController: UIViewController {
    
    var token: String? {
        get {
            let url = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(Const.UserDefaults.appGroupId)
            return NSDictionary(contentsOfURL: url!)![Const.Keychain.sharedAccountName] as? String
//            let defaults = NSUserDefaults(suiteName: Const.UserDefaults.appGroupId)!
//            defaults.synchronize()
//            return defaults.stringForKey(Const.Keychain.sharedAccountName)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for item: AnyObject in self.extensionContext!.inputItems {
            let inputItem = item as! NSExtensionItem
            for provider: AnyObject in inputItem.attachments! {
                let itemProvider = provider as! NSItemProvider
                itemProvider.loadItemForTypeIdentifier(kUTTypeItem as String, options: nil, completionHandler: { (result, error) in
                    if error != nil {
                        print(error)
                    } else {
                        if let url = result as? NSURL {
                            let urlString = url.absoluteString.componentsSeparatedByString("file://").last!
                            self.uploadDocument(urlString, documentName: "teeeest", completion: {
                                print("COMP")
                                self.dismissViewControllerAnimated(true, completion: nil)
                                }, progress: { (totalUploaded, bytesToUpload) in
                                    print("PROG", totalUploaded, bytesToUpload)
                                }, failure: { (error) in
                                    print("ERROR", error)
                                    self.dismissViewControllerAnimated(true, completion: nil)
                            })
                            
                        } else {
                            print("suka")
                        }
                    }
                })
            }
        }
    }

//    override func isContentValid() -> Bool {
//        // Do validation of contentText and/or NSExtensionContext attachments here
//        return true
//    }
//
//    override func didSelectPost() {
//        return
//        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
//    
//        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
//        self.extensionContext!.completeRequestReturningItems([], completionHandler: nil)
//    }
//    
//
//
//    override func configurationItems() -> [AnyObject]! {
//        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
//        return [SLComposeSheetConfigurationItem()]
//    }
    
    func uploadDocument(pathToFile: String, documentName: String, completion: () -> Void, progress: (totalUploaded: Int, bytesToUpload: Int) -> Void, failure: (error: String) -> Void) {
        Transport.sharedTransport.getJSON(Const.Network.baseUrl + "/docs.getUploadServer", parameters: ["access_token":token!], completion: { (json) -> Void in
            print(json)
//            if let error = self.checkError(json) {
//                Dispatch.mainQueue({ () -> () in
//                    NSNotificationCenter.defaultCenter().postNotificationName(Const.Notifications.uploadComplete, object: nil)
//                    failure(error: error)
//                })
//                return
//            }
            
            Transport.sharedTransport.uploadFile(self.parseServerUrlResponse(json), pathToFile: NSURL(fileURLWithPath: pathToFile), progressClosure: { (totalUploaded, totalToUpload) -> Void in
                Dispatch.mainQueue({ () -> () in
                    progress(totalUploaded: totalUploaded, bytesToUpload: totalToUpload)
                })
                }, completion: { (json) -> Void in
                    print(json)
//                    if let error = self.checkError(json) {
//                        Dispatch.mainQueue({ () -> () in
//                            NSNotificationCenter.defaultCenter().postNotificationName(Const.Notifications.uploadComplete, object: nil)
//                            failure(error: error)
//                        })
//                        return
//                    }
                    Transport.sharedTransport.getJSON(Const.Network.baseUrl + "/docs.save", parameters: self.saveParameters(documentName, vkFileParam: self.parseUploadResponse(json)), completion: { (json) -> Void in
                        print(json)
//                        if let error = self.checkError(json) {
//                            Dispatch.mainQueue({ () -> () in
//                                NSNotificationCenter.defaultCenter().postNotificationName(Const.Notifications.uploadComplete, object: nil)
//                                failure(error: error)
//                            })
//                            return
//                        }
                        Dispatch.mainQueue({ () -> () in
                            completion()
                        })
                        }, failure: { (error) -> Void in
                            let message = error.localizedDescription
                            failure(error: message)
                    })
                }, failure: { (error) -> Void in
                    let message = error.localizedDescription
                    failure(error: message)
            })
        }) { (error) -> Void in
            let message = error.localizedDescription
            failure(error: message)
        }
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
            "access_token": token!,
            "file":vkFileParam,
            "title":fileName
        ]
    }

}