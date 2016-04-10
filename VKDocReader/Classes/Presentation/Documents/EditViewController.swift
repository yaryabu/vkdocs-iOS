//
//  EditViewController.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 18/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit

import RealmSwift

enum EditActionType {
    case CreateFolder
    case EditFolder
    case EditDocument
}

class EditViewController: ViewController, UITextFieldDelegate {
    
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
    
    var actionType: EditActionType = .CreateFolder
    
    var documentToEdit: Document!
    var folderPathToEdit: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditViewController.keyboardWillShow(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)

        switch actionType {
        case .CreateFolder:
            navigationItem.title = "Новая папка"
            textField.text = ""
        case .EditDocument:
            navigationItem.title = "Изменить документ"
            createButton.enabled = true
            textField.text = documentToEdit.title
        case .EditFolder:
            navigationItem.title = "Изменить папку"
            textField.text = folderPathToEdit.componentsSeparatedByString("/").last!
            createButton.enabled = true
        }
        
        // GCD помогает с анимацией открытия клавиатуры
        Dispatch.mainQueue {
            self.textField.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        textField.resignFirstResponder()
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func createButtonPressed(sender: AnyObject) {
        performActionAndDismiss()
    }
    @IBAction func textFieldEditingChanged(sender: AnyObject) {
        if textField.text == "" {
            createButton.enabled = false
        } else {
            createButton.enabled = true
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        performActionAndDismiss()
        return true
    }
    
    func performActionAndDismiss() {
        let text = self.textField.text!
        
        if text.containsString("/") {
            let error = Error(code: 0, message: "Символ / не допускается")
            ToastManager.sharedInstance.presentError(error)
            return
        }
        
        if folderCreatedAlready(text) {
            let error = Error(code: 0, message: "Папка уже существует")
            ToastManager.sharedInstance.presentError(error)
            return
        }
        
        switch actionType {
        case .CreateFolder:
            Bash.mkdir(text)
            ToastManager.sharedInstance.presentInfo("Папка создана")
            Analytics.logUserCreatedFolder(Bash.pwd() + "/" + text)
            dismissViewControllerAnimated(true, completion: nil)
        case .EditFolder:
            Bash.mv(folderPathToEdit, to: Bash.pwd() + "/" + text)
            ToastManager.sharedInstance.presentInfo("Папка изменена")
            dismissViewControllerAnimated(true, completion: nil)
        case .EditDocument:
            serviceLayer.docsService.editDocument(documentToEdit, newDocumentName: text, completion: {
                let realm = try! Realm()
                try! realm.write({ 
                    self.documentToEdit.title = text
                })
                ToastManager.sharedInstance.presentInfo("Документ изменен")
                self.dismissViewControllerAnimated(true, completion: nil)
                }, failure: { (error) in
                    self.handleError(error)
            })
        }
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