//
//  CreateFolderViewController.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 18/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit

class CreateFolderViewController: ViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        textField.resignFirstResponder()
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
}