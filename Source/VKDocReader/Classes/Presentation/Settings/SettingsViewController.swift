//
//  SettingsViewController.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 14/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit
import MessageUI

import RealmSwift

class SettingsViewController: ViewController, MFMailComposeViewControllerDelegate {
    
    var notificationToken: NotificationToken?
    
    @IBOutlet weak var userAvatarImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userSurnameLabel: UILabel!
    
    @IBOutlet weak var totalDocumentsSizeLabel: UILabel!
    @IBOutlet weak var onlyWifiLoadSwitch: UISwitch!
    
    @IBOutlet weak var saveDocsAutomaticallySwitch: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.onlyWifiLoadSwitch.on = self.serviceLayer.userSettingsService.useWifiOnly
        self.saveDocsAutomaticallySwitch.on = !self.serviceLayer.userSettingsService.deleteDocumentsAfterPreview
        self.updateUserData()
        
        let realm = try! Realm()
        self.notificationToken = realm.objects(User).addNotificationBlock { results, error in
            //TODO: убрать спиннер
            self.updateUserData()
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Dispatch.mainQueue() { () -> () in
            self.totalDocumentsSizeLabel.text = "\(Bash.du(Const.Directories.vaultDir)/1024/1024) МБ занято"
        }
        
    }
    
    
    func updateUserData() {
        let realm = try! Realm()
        if let user = realm.objects(User).first {
            self.userNameLabel.text = user.firstName
            self.userSurnameLabel.text = user.lastName
            self.userAvatarImageView.image = UIImage(data: user.photoData!)
        } else {
            //TODO: добавить спиннер
        }
    }
    
    @IBAction func clearCacheButtonPressed(sender: AnyObject) {
        let alert = UIAlertController(title: "Что хотите удалить?", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        alert.view.backgroundColor = UIColor.redColor()
        let deleteAllAction = UIAlertAction(title: "Загруженные документы и папки", style: UIAlertActionStyle.Destructive) { (action) -> Void in
            Transport.sharedTransport.cancelAllDownloads()

            Bash.rm(Const.Directories.fileSystemDir)
            Bash.mkdir(Const.Directories.fileSystemDir)
            Bash.rm(Const.Directories.vaultDir)
            Bash.mkdir(Const.Directories.vaultDir)
        }
        let deleteOnlyFilesAction = UIAlertAction(title: "Только загруженные документы", style: .Default) { (action) -> Void in
            Transport.sharedTransport.cancelAllDownloads()

            Bash.rm(Const.Directories.vaultDir)
            Bash.mkdir(Const.Directories.vaultDir)
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .Default, handler: nil)
        alert.addAction(deleteAllAction)
        alert.addAction(deleteOnlyFilesAction)
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func onlyWifiLoadSwitchChanged(sender: AnyObject) {
        let wifiLoadSwitch = sender as! UISwitch
        if wifiLoadSwitch.on {
            self.serviceLayer.userSettingsService.useWifiOnly = true
        } else {
            self.serviceLayer.userSettingsService.useWifiOnly = false
        }
    }
    
    @IBAction func contactButtonPressed(sender: AnyObject) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["yaryabu@gmail.com"])
            mail.setMessageBody("<p>You're so awesome!</p>", isHTML: true)
            
            presentViewController(mail, animated: true, completion: nil)
        } else {
            // show failure alert
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func exitButtonPressed(sender: AnyObject) {
        let alert = UIAlertController(title: "Вы точно хотите выйти?", message: "Все документы и папки будут удалены из приложения", preferredStyle: UIAlertControllerStyle.Alert)
        let noAction = UIAlertAction(title: "Нет", style: .Cancel) { (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
        let yesAction = UIAlertAction(title: "Да", style: .Default) { (action) -> Void in
            self.serviceLayer.deleteAllInfo()
            let realm = try! Realm()
            try! realm.write({ () -> Void in
                realm.deleteAll()
            })
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            Bash.rm(Const.Directories.fileSystemDir)
            Bash.mkdir(Const.Directories.fileSystemDir)
            Bash.rm(Const.Directories.vaultDir)
            Bash.mkdir(Const.Directories.vaultDir)
            appDelegate.chooseInitialViewCotroller()
        }
        alert.addAction(noAction)
        alert.addAction(yesAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    @IBAction func saveDocsAutomaticallySwitchPressed(sender: AnyObject) {
        let docsSwitch = sender as! UISwitch
        if docsSwitch.on {
            self.serviceLayer.userSettingsService.deleteDocumentsAfterPreview = false
        } else {
            self.serviceLayer.userSettingsService.deleteDocumentsAfterPreview = true
        }

    }
}
