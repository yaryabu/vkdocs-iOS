//
//  AboutAppViewController.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 17/05/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit
import SafariServices
import MessageUI

class AboutAppViewController: ViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = "ABOUT_APP_VIEW_CONTROLLER_TITLE".localized
        }
    }
    @IBOutlet weak var shareButton: UIButton! {
        didSet {
            shareButton.setTitle("ABOUT_APP_VIEW_CONTROLLER_SHARE_WITH_FRIENDS".localized, forState: .Normal)
        }
    }
    @IBOutlet weak var vkCommunityButton: UIButton! {
        didSet {
            vkCommunityButton.setTitle("ABOUT_APP_VIEW_CONTROLLER_VK_COMMUNITY".localized, forState: .Normal)
        }
    }
    @IBOutlet weak var contactDeveloper: UIButton! {
        didSet {
            contactDeveloper.setTitle("ABOUT_APP_VIEW_CONTROLLER_CONTACT_DEVELOPER".localized, forState: .Normal)
        }
    }
    
    @IBOutlet weak var rateInAppStoreButton: UIButton! {
        didSet {
            rateInAppStoreButton.setTitle("ABOUT_APP_VIEW_CONTROLLER_RATE_IN_APP_STORE".localized, forState: .Normal)
        }
    }
    
    
    @IBAction func closeScreenButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func shareButtonPressed(sender: AnyObject) {
        let activityVC = UIActivityViewController(activityItems: [Const.ExternalLinks.appStoreShortLink], applicationActivities: nil)
        presentViewController(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func openVkCommunityButtonPressed(sender: AnyObject) {
        if #available(iOS 9.0, *) {
            let safariVC = SFSafariViewController(URL: NSURL(string: Const.ExternalLinks.vkDocsVkPublicUrlString)!, entersReaderIfAvailable: true)
            self.presentViewController(safariVC, animated: true, completion: nil)
        } else {
            UIApplication.sharedApplication().openURL(NSURL(string: Const.ExternalLinks.vkDocsVkPublicUrlString)! )
        }
    }
    @IBAction func contactDeveloperButtonPressed(sender: AnyObject) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["yaryabu@gmail.com"])
            mail.setSubject("VK Docs")
            mail.setMessageBody("\n\n\n\n Device: \(Const.DeviceInfo.fullInfo)\nApp Version: \(Const.Common.fullVersion)", isHTML: false)
            
            presentViewController(mail, animated: true, completion: nil)
        } else {
            ToastManager.sharedInstance.presentError(Error(code: 0, message: "SETTINGS_VIEW_CONTROLLER_EMAIL_NOT_SET_ERROR".localized))
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func rateInAppStoreButtonPressed(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: Const.ExternalLinks.appStoreRateAppUrlString)!)
    }
}
