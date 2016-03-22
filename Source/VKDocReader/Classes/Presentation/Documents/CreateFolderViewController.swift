//
//  CreateFolderViewController.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 18/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit

class CreateFolderViewController: ViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.font = UIFont.createFolderFieldFont()
            textField.textColor = UIColor.vkWarmGreyColor()
            textField.tintColor = UIColor.vkDuskBlueColor()
        }
    }
    
    @IBOutlet weak var bottomSpacing: NSLayoutConstraint!
    let navBarDividerOvarlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.vkWhiteColor()
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)

        
        textField.becomeFirstResponder()
        navBarDividerOvarlay.frame = CGRect(
            x: 0,
            y: navigationController!.navigationBar.frame.origin.x + navigationController!.navigationBar.frame.height - 2,
            width: view.frame.width,
            height: 5
        )
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController!.navigationBar.addSubview(navBarDividerOvarlay)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        textField.resignFirstResponder()
        navBarDividerOvarlay.removeFromSuperview()
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func createButtonPressed(sender: AnyObject) {
        createFolder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        createFolder()
        return true
    }
    
    func createFolder() {
        let text = self.textField.text!
        
        if text == "" || folderCreatedAlready(text) {
            //TODO: добавить ошибку
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