//
//  CreateFolderViewController.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 18/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit

class CreateFolderViewController: ViewController, UITextFieldDelegate {
    
    @IBOutlet weak var createButton: UIBarButtonItem! {
        didSet {
            createButton.enabled = false
        }
    }
    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.font = UIFont.createFolderFieldFont()
            textField.textColor = UIColor.vkWarmGreyColor()
            textField.tintColor = UIColor.vkDuskBlueColor()
            textField.enablesReturnKeyAutomatically = true
        }
    }
    
    @IBOutlet weak var bottomSpacing: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)

        
        textField.becomeFirstResponder()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        textField.resignFirstResponder()
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func createButtonPressed(sender: AnyObject) {
        createFolder()
    }
    @IBAction func textFieldEditingChanged(sender: AnyObject) {
        if textField.text == "" {
            createButton.enabled = false
        } else {
            createButton.enabled = true
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        createFolder()
        return true
    }
    
    func createFolder() {
        let text = self.textField.text!
        
        if folderCreatedAlready(text) {
            let error = Error(code: 0, message: "Папка уже существует")
            ToastManager.sharedInstance.presentError(error)
            return
        }
        if text.containsString("/") {
            let error = Error(code: 0, message: "Символ / не допускается")
            ToastManager.sharedInstance.presentError(error)
            return
        }
        
        Bash.mkdir(text)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func folderCreatedAlready(folderName: String) -> Bool {
        let folders = Bash.ls(".")
        for folder in folders {
            if folder == folderName {
                return true
            }
        }
        return false
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let keyboardHeight = keyboardFrame.height
        let animationDuration = info[UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
        self.bottomSpacing.constant = keyboardHeight
        
        UIView.animateWithDuration(animationDuration) { () -> Void in
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let info = notification.userInfo!
        let animationDuration = info[UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
        self.bottomSpacing.constant = 0
        
        UIView.animateWithDuration(animationDuration) { () -> Void in
            self.view.layoutIfNeeded()
        }
    }
    
}