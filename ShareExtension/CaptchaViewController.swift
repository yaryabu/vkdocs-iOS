//
//  CaptchaViewController.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 04/04/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit

import SwiftyJSON

class CaptchaViewController: UIViewController, UITextFieldDelegate {
    
    var captchaError: Error!
    var captchaDelegate: ShareViewController!
    var captchaSuccessClosure: (() -> ())!
    
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
        }
    }
    
    @IBOutlet weak var cancelButton: UIButton!
    
    class func presentCaptchaViewController(error: Error, captchaSuccessClosure: () -> (), presentingViewController: ShareViewController) {
        let storyboard = UIStoryboard(name: "CaptchaViewController", bundle: nil)
        let captchaVC = storyboard.instantiateViewControllerWithIdentifier("azaza") as! CaptchaViewController
        
        captchaVC.captchaError = error
        captchaVC.captchaSuccessClosure = captchaSuccessClosure
        captchaVC.captchaDelegate = presentingViewController
        presentingViewController.presentViewController(captchaVC, animated: true, completion: nil)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Transport.sharedTransport.getData(captchaError.captchaUrlString!, completion: { (data) -> Void in
            let image = UIImage(data: data)
            Dispatch.mainQueue({ () -> () in
                self.imageView.image = image
            })
            }, failure: { (error) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
        })
        
        textField.becomeFirstResponder()
        
    }
    
    func submitCaptchaAndDismiss() {
        
        submitCaptcha(captchaError, captchaText: textField.text!, completion: {
            self.captchaSuccessClosure()
            }) { (error) in
                self.captchaDelegate.handleError(error, retryClosure: self.captchaSuccessClosure)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
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
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func submitCaptcha(error: Error, captchaText: String, completion: () -> Void, failure: (error: Error) -> Void) {
        let requestInfo = retryRequestParameters(error, captchaText: captchaText)
        Transport.sharedTransport.getJSON(Const.Network.baseUrl + requestInfo.method, parameters: requestInfo.queryParams, completion: { (json) in
            if let error = self.captchaDelegate.checkError(json) {
                Dispatch.mainQueue({ () -> () in
                    failure(error: error)
                })
                return
            }
            Dispatch.mainQueue({ () -> () in
                completion()
            })
        }) { (error) in
            failure(error: Error())
        }
    }
    
    func retryRequestParameters(error: Error, captchaText: String) -> (method: String, queryParams: [String:String]) {
        
        var method: String!
        var params: [String:String] = [:]
        
        for (_,subJson):(String, JSON) in error.requestParams! {
            if subJson["key"].string! == "oauth" {
                continue
            } else if subJson["key"].string! == "method" {
                method = "/" + subJson["value"].string!
            } else {
                params[subJson["key"].string!] = subJson["value"].string!
            }
        }
        params["captcha_key"] = captchaText
        params["captcha_sid"] = error.captchaId
        
        params["access_token"] = captchaDelegate.token
        
        return (method: method, queryParams: params)
    }
}
