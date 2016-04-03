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

import SwiftyJSON
import SSKeychain
import Alamofire

struct FileToUpload {
    let name: String
    let fileSystemUrl: NSURL
    
    init(name: String, fileSystemUrl: NSURL) {
        self.name = name
        self.fileSystemUrl = fileSystemUrl
    }
}

class ShareViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    static let cellIdentifier = "ShareCell"
    
    var token: String? {
        get {
            
            let defaults = NSUserDefaults(suiteName: Const.UserDefaults.appGroupId)
            defaults?.synchronize()
            print(defaults?.stringForKey(Const.UserDefaults.userToken))
            return defaults?.stringForKey(Const.UserDefaults.userToken)
        }
    }
    
    var attachmentsCount: Int = -1
    
    var filesToUpload: [FileToUpload] = [] {
        didSet {
            if filesToUpload.count == attachmentsCount {
                beginUploading()
                //begin
            }
        }
    }
    
    var uploadedDocumentsCount: Int = 0 {
        didSet {
            if uploadedDocumentsCount == attachmentsCount {
                print("COMPLEEEEETEEEE")
                extensionContext?.completeRequestReturningItems(nil, completionHandler: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        UINavigationBar.appearance().titleTextAttributes = [
            NSFontAttributeName: UIFont.navigationBarFont(),
            NSForegroundColorAttributeName: UIColor.vkBlackColor()
        ]
        
        UINavigationBar.appearance().tintColor = UIColor.vkBlackColor()
        
        //в связке с "Status bar style" в Info.plist помогает убрать дивайдер под навбаром
        UINavigationBar.appearance().tintColor = UIColor.vkWhiteColor()
//        navigationBar.barStyle = .Black
//        navigationBar.barTintColor = UIColor.vkWhiteColor()
        
        //present loader
        for item: AnyObject in self.extensionContext!.inputItems {
            let inputItem = item as! NSExtensionItem
            attachmentsCount = inputItem.attachments!.count
            for provider: AnyObject in inputItem.attachments! {
                let itemProvider = provider as! NSItemProvider
                print("COUNT", inputItem.attachments!.count)
                itemProvider.loadItemForTypeIdentifier(kUTTypeItem as String, options: nil, completionHandler: { (result, error) in
                    if let url = result as? NSURL {
                        print(url.path)
                        let file = FileToUpload(
                            name: url.absoluteString.componentsSeparatedByString("/").last ?? "VK_Docs_File",
                            fileSystemUrl: url
                        )
                        self.filesToUpload.append(file)
                    }
                })
            }
        }
    }
    
    func beginUploading() {
        for file in filesToUpload {
            self.uploadDocument(file.fileSystemUrl, documentName: file.name, completion: {
                print("COMP")
                self.uploadedDocumentsCount += 1
                }, progress: { (totalUploaded, bytesToUpload) in
                    print("PROG", totalUploaded, bytesToUpload)
                }, failure: { (error) in
                    print("ERROR", error)
            })
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ShareViewController.cellIdentifier, forIndexPath: indexPath)
        
        return cell
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
    
    func uploadDocument(fileUrl: NSURL, documentName: String, completion: () -> Void, progress: (totalUploaded: Int, bytesToUpload: Int) -> Void, failure: (error: String) -> Void) {
        Transport.sharedTransport.getJSON(Const.Network.baseUrl + "/docs.getUploadServer", parameters: ["access_token":token!], completion: { (json) -> Void in
            
            if let error = self.checkError(json) {
                Dispatch.mainQueue({ () -> () in
                    failure(error: error)
                })
                return
            }
            
            Transport.sharedTransport.upload(.POST, self.parseServerUrlResponse(json), multipartFormData: { (multipart) in
                multipart.appendBodyPart(fileURL: fileUrl, name: "file")
                }, encodingCompletion: { (encodingResult) in
                    switch encodingResult {
                    case .Success(let upload, _, _):
                        upload
                            .progress({ (uploaded, totalUploaded, totalToUpload) -> Void in
                                progress(totalUploaded: Int(totalUploaded), bytesToUpload: Int(totalToUpload))
                            })
                            .responseJSON { (response) -> Void in
                                switch response.result {
                                case .Success:
                                    if let value = response.result.value {
                                        Dispatch.defaultQueue({ () -> () in
                                            let json = JSON(value)
                                            Transport.sharedTransport.getJSON(Const.Network.baseUrl + "/docs.save", parameters: self.saveParameters(documentName, vkFileParam: self.parseUploadResponse(json)), completion: { (json) -> Void in
                                                if let error = self.checkError(json) {
                                                    Dispatch.mainQueue({ () -> () in
                                                        failure(error: error)
                                                    })
                                                    return
                                                }
                                                Dispatch.mainQueue({ () -> () in
                                                    completion()
                                                })
                                                }, failure: { (error) -> Void in
                                                    print(error)
                                                    failure(error: "Неизвестная ошибка")
                                            })
                                        })
                                    }
                                case .Failure:
                                    failure(error: "Неизвестная ошибка")
                                }
                        }
                    case .Failure:
                        failure(error: "Неизвестная ошибка")
                    }
                    
            })
        }) { (error) -> Void in
            failure(error: "Неизвестная ошибка")
        }
    }
    
    @IBAction func exitButtonPressed(sender: AnyObject) {
        let alert = UIAlertController(title: nil, message: "Вы точно хотите прервать загрузку в ВК?", preferredStyle: UIAlertControllerStyle.Alert)
        
        let yesAction = UIAlertAction(title: "Да", style: .Default) { (action) in
            let error = NSError(domain: Const.Common.errorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey : "User cancelled upload"])
            self.extensionContext?.cancelRequestWithError(error)
        }
        
        let noAction = UIAlertAction(title: "Нет", style: UIAlertActionStyle.Cancel, handler: nil)
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    private func checkError(json: JSON) -> String? {
        if json["error"] != nil {
            return "Неизвестная ошибка"
        }
        return nil
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