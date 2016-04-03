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
    
    var isUploadComplete: Bool = false
    
    init(name: String, fileSystemUrl: NSURL) {
        self.name = name
        self.fileSystemUrl = fileSystemUrl
    }
}

class ShareViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var shareNavigationItem: UINavigationItem!
    
    let titleTemplate = "Загружено %d из %d"
    
    var token: String? {
        get {
            
            let defaults = NSUserDefaults(suiteName: Const.UserDefaults.appGroupId)
            defaults?.synchronize()
            print(defaults?.stringForKey(Const.UserDefaults.userToken))
            return defaults?.stringForKey(Const.UserDefaults.userToken)
        }
    }
    @IBOutlet weak var tableView: UITableView!
    
    var attachmentsCount: Int = -1
    
    var filesToUpload: [FileToUpload] = [] {
        didSet {
//            if filesToUpload.count == attachmentsCount {
//                print("BEGIN")
//                beginUploading()
                //begin
//                if filesToUpload.count > 0 {
//                    for file in filesToUpload {
//                        if file.isUploadComplete == false {
//                            file.uploadRequest?.resume()
//                        }
//                    }
//                }
//            }
        }
    }
    
    
    var uploadedDocumentsCount: Int = 0 {
        didSet {
            shareNavigationItem.title = String(format: titleTemplate, uploadedDocumentsCount, attachmentsCount)

            if uploadedDocumentsCount == attachmentsCount {
                let okAction = UIAlertAction(title: "Ясно", style: UIAlertActionStyle.Default, handler: { (action) in
                    self.extensionContext?.completeRequestReturningItems(nil, completionHandler: nil)
                })
                let ok2Action = UIAlertAction(title: "Понятно", style: UIAlertActionStyle.Default, handler: { (action) in
                    self.extensionContext?.completeRequestReturningItems(nil, completionHandler: nil)
                })
                
                let alert = UIAlertController(title: nil, message: "Документы успешно загружены в ВК", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(okAction)
                alert.addAction(ok2Action)
                presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        Transport.sharedTransport.startRequestsImmediately = false
        
        UINavigationBar.appearance().titleTextAttributes = [
            NSFontAttributeName: UIFont(name: "Open Sans", size: 18)!,
            NSForegroundColorAttributeName: UIColor.vkBlackColor()
        ]
        UINavigationBar.appearance().tintColor = UIColor.vkBlackColor()
        
        //present loader
        for item: AnyObject in self.extensionContext!.inputItems {
            let inputItem = item as! NSExtensionItem
            attachmentsCount = inputItem.attachments!.count
            for provider: AnyObject in inputItem.attachments! {
                let itemProvider = provider as! NSItemProvider
                itemProvider.loadItemForTypeIdentifier(kUTTypeItem as String, options: nil, completionHandler: { (result, error) in
                    if let url = result as? NSURL {
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if filesToUpload.count == attachmentsCount {
            print("BEGIN")
            beginUploading()
        }
        
        shareNavigationItem.title = String.localizedStringWithFormat(titleTemplate, uploadedDocumentsCount, attachmentsCount)
    }
    
//    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        if attachmentsCount == filesToUpload.count {
//        
//            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
//        }
//    }
    
    func beginUploadingNextFile() {
        var fileToUpload: FileToUpload?
        var cellIndex: Int?
        if filesToUpload.count > 0 {
            for (i, file) in filesToUpload.enumerate() {
                if file.isUploadComplete == false {
//                    file.uploadRequest?.resume()
                    fileToUpload = file
                    cellIndex = i
                    print("FILE", cellIndex!, fileToUpload!.name)
                    break
                }
            }
        }
        
        if fileToUpload == nil || cellIndex == nil {
            return
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(UploadingFileCell.cellIdentifier, forIndexPath: NSIndexPath(forRow: cellIndex!, inSection: 0)) as! UploadingFileCell
        
        let completion: () -> () = {
            cell.progressLabel.text = "Загружено"
            
            self.uploadedDocumentsCount += 1
            
            self.filesToUpload.removeAtIndex(cellIndex!)
            self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: cellIndex!, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
            
            self.beginUploadingNextFile()
            
        }
        
        self.uploadDocument(fileToUpload!.fileSystemUrl, documentName: fileToUpload!.name, completion: completion, progress: { (totalUploaded, bytesToUpload) in
                let percent = Int((Double(totalUploaded)/Double(bytesToUpload))*100)
                if percent == 100 {
                    cell.progressLabel.text = "Обработка"
                } else {
                    cell.progressLabel.text = "\(percent) %"
                }
            }, failure: { (error) in
                print("EPIC ERROR", error)
                self.handleError(error, retryClosure: completion)
                
        })
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: cellIndex!, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    func beginUploading() {
        self.tableView.reloadData()
        beginUploadingNextFile()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filesToUpload.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(UploadingFileCell.cellIdentifier, forIndexPath: indexPath) as! UploadingFileCell
        
        let file = filesToUpload[indexPath.row]
        cell.fileNameLabel.text = file.name
        
        return cell
    }
    
    func handleError(error: Error, retryClosure: () -> ()) {
        switch error.code {
        case 14:
//            print("")
            // captcha
            print("RETRY")
            retryClosure()
        default:
            let alert = UIAlertController(title: "Ошибка", message: "Неизвестная ошибка", preferredStyle: UIAlertControllerStyle.Alert)
            presentViewController(alert, animated: true, completion: { 
                Dispatch.mainQueueAfter(2.0, closure: {
                    alert.removeFromParentViewController()
                    retryClosure()
                })
            })
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
    
    func uploadDocument(fileUrl: NSURL, documentName: String, completion: () -> Void, progress: (totalUploaded: Int, bytesToUpload: Int) -> Void, failure: (error: Error) -> Void) {
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
                                Dispatch.mainQueue({ 
                                    progress(totalUploaded: Int(totalUploaded), bytesToUpload: Int(totalToUpload))
                                    print("PROG", totalUploaded, totalToUpload)
                                })
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
                                                    failure(error: self.createError(error))
                                            })
                                        })
                                    }
                                case .Failure:
                                    failure(error: self.createError())
                                }
                        }
                    case .Failure:
                        failure(error: self.createError())
                    }
                    
            })
        }) { (error) -> Void in
            failure(error: self.createError(error))
        }
    }
    
    func createError(error: NSError? = nil) -> Error {
        print(error)
        return Error(code: 0, message: "Неизвестная ошибка")
    }
    
    @IBAction func exitButtonPressed(sender: AnyObject) {
        let alert = UIAlertController(title: nil, message: "Вы точно хотите прервать загрузку в ВК?", preferredStyle: UIAlertControllerStyle.Alert)
        
        let yesAction = UIAlertAction(title: "Да", style: .Default) { (action) in
            let error = NSError(domain: Const.Common.errorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey : "User cancelled upload"])
            self.extensionContext?.cancelRequestWithError(error)
//            self.extensionContext?.completeRequestReturningItems(nil, completionHandler: nil)
        }
        
        let noAction = UIAlertAction(title: "Нет", style: UIAlertActionStyle.Cancel, handler: nil)
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    private func checkError(json: JSON) -> Error? {
        if json["error"] != nil {
            print("========JSON ERROR========")
            print(json)
            if let errorCode = json["error"]["error_code"].int {
                switch errorCode {
                case 14:
                    var newError =  Error(code: 14, message: "Необходимо ввести код с картинки")
                    newError.captchaId = json["error"]["captcha_sid"].string!
                    newError.captchaUrlString = json["error"]["captcha_img"].string!
                    newError.requestParams = json["error"]["request_params"]
                    return newError
                default:
                    return Error()
                }
            } else {
                return Error()
            }
        }
        return nil
    }
    
    private func parseServerUrlResponse(json: JSON) -> String {
        let serverUrl = json["response"]["upload_url"].string!
        print("PARSE URL", json)
        return serverUrl
    }
    
    private func parseUploadResponse(json: JSON) -> String {
        print("PARSE FILE", json)
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