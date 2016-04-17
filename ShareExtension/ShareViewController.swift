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

func logShareExtensionDocuments(fileNames: [String]) {
    var extensions: [String] = []
    for name in fileNames {
        extensions.append(name.componentsSeparatedByString(".").last ?? "error")
    }
    let defaults = NSUserDefaults(suiteName: Const.UserDefaults.appGroupId)
    defaults?.synchronize()
    defaults?.setObject(extensions, forKey: Const.UserDefaults.shareExtensionDocumentsExtensions)
}

class ShareViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    static let authSegueIdentifier = "authWebView"
    
    @IBOutlet weak var shareNavigationItem: UINavigationItem!
    
    let titleTemplate = "Загружено %d из %d"
    
    var token: String? {
        get {
            let defaults = NSUserDefaults(suiteName: Const.UserDefaults.appGroupId)
            defaults?.synchronize()
            return defaults?.stringForKey(Const.UserDefaults.userToken)
        }
        set {
            let defaults = NSUserDefaults(suiteName: Const.UserDefaults.appGroupId)
            defaults?.synchronize()
            defaults?.setObject(newValue, forKey: Const.UserDefaults.userToken)
        }
    }
    
    var userId: String? {
        get {
            let defaults = NSUserDefaults(suiteName: Const.UserDefaults.appGroupId)
            defaults?.synchronize()
            return defaults?.stringForKey(Const.UserDefaults.userIdKey)
        }
        set {
            let defaults = NSUserDefaults(suiteName: Const.UserDefaults.appGroupId)
            defaults?.synchronize()
            defaults?.setObject(newValue, forKey: Const.UserDefaults.userIdKey)
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var attachmentsCount: Int = -1
    
    var filesToUpload: [FileToUpload] = []
    
    
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
        
        if token == nil {
            self.performSegueWithIdentifier(ShareViewController.authSegueIdentifier, sender: nil)
            return
        }
        
        if filesToUpload.count == attachmentsCount {
            print("BEGIN")
            beginUploading()
        }
        
        shareNavigationItem.title = String.localizedStringWithFormat(titleTemplate, uploadedDocumentsCount, attachmentsCount)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == ShareViewController.authSegueIdentifier {
            let destinationVC = segue.destinationViewController as! UINavigationController
            let authWebView = destinationVC.viewControllers[0] as! AuthWebViewController
            authWebView.authDelegate = self
        }
    }
    
    func saveAuthData(paramsString: String) {
        let params = paramsString.componentsSeparatedByString("&")
        
        for param in params {
            if param.containsString("access_token") {
                self.token = param.componentsSeparatedByString("=")[1]
            } else if param.containsString("user_id") {
                self.userId = param.componentsSeparatedByString("=")[1]
            }
        }
        
        if filesToUpload.count == attachmentsCount {
            beginUploading()
        }
        
        shareNavigationItem.title = String.localizedStringWithFormat(titleTemplate, uploadedDocumentsCount, attachmentsCount)
    }
    
    func beginUploadingNextFile() {
        var fileToUpload: FileToUpload?
        var cellIndex: Int?
        if filesToUpload.count > 0 {
            fileToUpload = filesToUpload.first!
            cellIndex = 0
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
        NSHTTPCookieStorage.sharedHTTPCookieStorage().removeCookiesSinceDate(NSDate.init(timeIntervalSince1970: -1000))
        
        self.tableView.reloadData()
        beginUploadingNextFile()
        
        var filenames: [String] = []
        
        for file in filesToUpload {
            filenames.append(file.name)
        }
        logShareExtensionDocuments(filenames)
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filesToUpload.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(UploadingFileCell.cellIdentifier, forIndexPath: indexPath) as! UploadingFileCell
        
        let file = filesToUpload[indexPath.row]
        cell.fileNameLabel.text = "  \(file.name)"
        cell.progressLabel.text = "0 %"
        
        return cell
    }
    
    func handleError(error: Error, retryClosure: () -> ()) {
        switch error.code {
        case 14:
            CaptchaViewController.presentCaptchaViewController(error, captchaSuccessClosure: retryClosure, presentingViewController: self)
        default:
            let alert = UIAlertController(title: "Ошибка", message: error.message, preferredStyle: UIAlertControllerStyle.Alert)
            presentViewController(alert, animated: true, completion: { 
                Dispatch.mainQueueAfter(2.0, closure: {
                    alert.dismissViewControllerAnimated(true, completion: nil)
                    //TODO: надо еще подумать, нужен ли повторный запрос
                    self.beginUploadingNextFile()
                })
            })
        }
    }
    
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
                                            
                                            if let error = self.checkError(json) {
                                                Dispatch.mainQueue({ () -> () in
                                                    failure(error: error)
                                                })
                                                return
                                            }
                                            
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
                                case .Failure(let error):
                                    failure(error: self.createError(error))
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
        print("NS_ERROR", error)
        return Error(code: 0, message: "Неизвестная ошибка\nПовторяем загрузку")
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
    
    func checkError(json: JSON) -> Error? {
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