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
    
    @IBOutlet weak var clearCacheButton: UIButton!
    @IBOutlet weak var userAvatarImageBarButton: UIBarButtonItem!
    
    @IBOutlet weak var contactDeveloperButton: UIButton!
    @IBOutlet weak var onlyWifiLoadSwitch: UISwitch!
    
    @IBOutlet weak var saveDocsAutomaticallySwitch: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearCacheButton.setTitleColor(UIColor.vkBlackTwoColor(), forState: UIControlState.Normal)
        self.clearCacheButton.titleLabel!.font = UIFont.defaultFont()
        
        self.contactDeveloperButton.setTitleColor(UIColor.vkBlackTwoColor(), forState: UIControlState.Normal)
        self.contactDeveloperButton.titleLabel!.font = UIFont.defaultFont()
        
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
        refreshCacheSize()
    }
    
    
    func updateUserData() {
        let realm = try! Realm()
        if let user = realm.objects(User).first {
            let label = UserNameLabel()
            label.frame = CGRect(x: 20, y: 8, width: 200, height: 40)
            label.text = user.firstName + " " + user.lastName
//            self.userSurnameLabel.text = user.lastName
            label.transform = CGAffineTransformMakeTranslation(-38, -8)
            let container = UIView(frame: label.frame)
            container.addSubview(label)
            navigationItem.titleView = container
            let avatarImageView = UIImageView(image: UIImage(data: user.photoData!))
            avatarImageView.layer.masksToBounds = true
            avatarImageView.layer.cornerRadius = 15
            avatarImageView.frame = CGRect(
                x: 0,
                y: 0,
                width: 30,
                height: 30
            )
            avatarImageView.transform = CGAffineTransformMakeTranslation(-10, 0)
            let imageViewContainer = UIView(frame: avatarImageView.frame)
            imageViewContainer.addSubview(avatarImageView)
//            let suggestButtonItem = UIBarButtonItem(customView: suggestButtonContainer)
            let button = UIBarButtonItem(customView: imageViewContainer)
            navigationItem.leftBarButtonItem = button
//            self.userAvatarImageBarButton = button
        } else {
            //TODO: добавить спиннер
        }
    }
    
    @IBAction func clearCacheButtonPressed(sender: AnyObject) {
        let alert = UIAlertController(title: "Что хотите удалить?", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let deleteAllAction = UIAlertAction(title: "Загруженные документы и папки", style: UIAlertActionStyle.Destructive) { (action) -> Void in
            LoadTaskManager.sharedManager.cancelAllDownloads()

            Bash.rm(Const.Directories.fileSystemDir)
            Bash.mkdir(Const.Directories.fileSystemDir)
            Bash.rm(Const.Directories.vaultDir)
            Bash.mkdir(Const.Directories.vaultDir)
            self.refreshCacheSize()
            ToastManager.sharedInstance.presentInfo("Документы и папки удалены")
        }
        let deleteOnlyFilesAction = UIAlertAction(title: "Только загруженные документы", style: .Default) { (action) -> Void in
            LoadTaskManager.sharedManager.cancelAllDownloads()

            Bash.rm(Const.Directories.vaultDir)
            Bash.mkdir(Const.Directories.vaultDir)
            self.refreshCacheSize()
            ToastManager.sharedInstance.presentInfo("Кэш удален")

        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .Cancel, handler: nil)
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
        launchExitAppSequence()
    }
    @IBAction func saveDocsAutomaticallySwitchPressed(sender: AnyObject) {
        let docsSwitch = sender as! UISwitch
        if docsSwitch.on {
            self.serviceLayer.userSettingsService.deleteDocumentsAfterPreview = false
        } else {
            self.serviceLayer.userSettingsService.deleteDocumentsAfterPreview = true
        }

    }
    
    func refreshCacheSize() {
        let cacheSize = SizeFormatter.closestFormatFromBytes(Bash.du(Const.Directories.vaultDir))
        let cacheSizeString = String(cacheSize.number) + " " + cacheSize.unitTypeName
        self.clearCacheButton.setTitle("Очистить кэш – \(cacheSizeString) занято", forState: UIControlState.Normal)
    }
}
