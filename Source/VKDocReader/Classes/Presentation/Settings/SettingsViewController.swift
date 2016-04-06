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
//    @IBOutlet weak var userAvatarImageView: UIImageView!
    
//    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var contactDeveloperButton: UIButton!
    @IBOutlet weak var onlyWifiLoadSwitch: UISwitch!
    
    lazy var navBarOverlay: NavBarOverlay = {
        let overay = NavBarOverlay.loadFromNibNamed("NavBarOverlay")
        overay.frame = CGRect(
            x: 0,
            y: 0,
            width: self.navigationController!.navigationBar.frame.width,
            height: self.navigationController!.navigationBar.frame.height - 2 // для лоудера загрузки в вк
        )
        
        overay.exitAppButton.addTarget(self, action: #selector(SettingsViewController.exitButtonPressed(_:)), forControlEvents: .TouchUpInside)

        
        self.navigationController!.navigationBar.addSubview(overay)
        
        return overay
    }()
    
    @IBOutlet weak var saveDocsAutomaticallySwitch: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
        let _ = navBarOverlay
        self.clearCacheButton.setTitleColor(UIColor.vkBlackTwoColor(), forState: UIControlState.Normal)
        self.clearCacheButton.titleLabel!.font = UIFont.defaultFont()
        
        self.contactDeveloperButton.setTitleColor(UIColor.vkBlackTwoColor(), forState: UIControlState.Normal)
        self.contactDeveloperButton.titleLabel!.font = UIFont.defaultFont()
        
        self.onlyWifiLoadSwitch.on = self.serviceLayer.userSettingsService.useWifiOnly
        self.saveDocsAutomaticallySwitch.on = !self.serviceLayer.userSettingsService.deleteDocumentsAfterPreview
        self.updateUserData()
        
        let realm = try! Realm()
        self.notificationToken = realm.objects(User).addNotificationBlock { results, error in
            self.updateUserData()
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshCacheSize()
    }
    
    
    func updateUserData() {
        if let user = try! Realm().objects(User).first {
            navBarOverlay.usernameLabel.text = user.firstName + " " + user.lastName
            
            if user.photoData != nil {
                navBarOverlay.userAvatarImageView.image = UIImage(data: user.photoData!)
            } else {
                navBarOverlay.userAvatarImageView.image = UIImage()
            }
        } else {
            //FIXME: добавить спиннер
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
        self.serviceLayer.userSettingsService.useWifiOnly = wifiLoadSwitch.on
        Analytics.logUseWifiOnlySetting(wifiLoadSwitch.on)
    }
    
    @IBAction func contactButtonPressed(sender: AnyObject) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["yaryabu@gmail.com"])
            mail.setSubject("VK Docs")
            mail.setMessageBody("", isHTML: false)
            
            presentViewController(mail, animated: true, completion: nil)
        } else {
            ToastManager.sharedInstance.presentError(Error(code: 0, message: "Связь барахлит.\nПроверь настройки почты."))
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func exitButtonPressed(sender: AnyObject) {
        launchExitAppSequence()
    }
    
    @IBAction func saveDocsAutomaticallySwitchPressed(sender: AnyObject) {
        let docsSwitch = sender as! UISwitch
        self.serviceLayer.userSettingsService.deleteDocumentsAfterPreview = !docsSwitch.on
        Analytics.logSaveDocsAfterPreviewSetting(docsSwitch.on)
    }
    
    func refreshCacheSize() {
        
        let bytes = Bash.du(Const.Directories.vaultDir)
        
        Analytics.logCacheSize(bytes)
        
        let cacheSize = SizeFormatter.closestFormatFromBytes(bytes)
        let cacheSizeString = String(cacheSize.number) + " " + cacheSize.unitTypeName
        self.clearCacheButton.setTitle("Очистить кэш – \(cacheSizeString) занято", forState: UIControlState.Normal)
    }
}
