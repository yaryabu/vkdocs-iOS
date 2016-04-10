//
//  CaptchaViewController.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 04/04/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit

class CaptchaViewController: UIViewController, UITextFieldDelegate {
    
    var captchaError: Error!
    
    var captchaSuccessClosure: () -> () = {
        ToastManager.sharedInstance.presentInfo("CAPTCHA_SUCCESS_MESSAGE".localized)
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField! {
        didSet {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
            textField.leftView = view
            textField.leftViewMode = UITextFieldViewMode.Always
        }
    }
    
    @IBOutlet weak var doneButton: UIButton! {
        didSet {
            doneButton.enabled = false
            doneButton.setTitle("CAPTCHA_OK_BUTTON".localized, forState: .Normal)
        }
    }
    @IBOutlet weak var cancelButton: UIButton! {
        didSet {
            cancelButton.setTitle("CAPTCHA_CANCEL_BUTTON".localized, forState: .Normal)
        }
    }
    
    
    class func presentCaptchaViewController(error: Error) {
        let storyboard = UIStoryboard(name: "CaptchaViewController", bundle: nil)
        let captchaVC = storyboard.instantiateViewControllerWithIdentifier(Const.StoryboardIDs.captchaViewController) as! CaptchaViewController
        
        captchaVC.captchaError = error
        let rootVC = UIApplication.sharedApplication().keyWindow!.rootViewController!
        rootVC.presentViewController(captchaVC, animated: true, completion: nil)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "CAPTCHA_TITLE".localized
        
        serviceLayer.imageService.getImage(captchaError.captchaUrlString!, completion: { (imageData) in
            let image = UIImage(data: imageData)
            self.imageView.image = image
            }) { (error) in
                self.handleError(error)
                // если капча не подгрузилась, то смысл держать человека на экране
                self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        textField.becomeFirstResponder()
        
    }
    
    func submitCaptchaAndDismiss() {
        
        serviceLayer.retryErrorService.submitCaptcha(captchaError, captchaText: textField.text!, completion: {
            self.captchaSuccessClosure()
            Analytics.logCaptcha(true, canceled: false)
            }) { (error) in
                Analytics.logCaptcha(false, canceled: false)
                self.handleError(error)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func textFieldEditingChanged(sender: AnyObject) {
        if textField.text == "" {
            doneButton.enabled = false
        } else {
            doneButton.enabled = true
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        submitCaptchaAndDismiss()
        return true
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        submitCaptchaAndDismiss()
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        Analytics.logCaptcha(false, canceled: true)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
