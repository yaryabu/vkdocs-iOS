//
//  ViewController.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 05/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    lazy var isRootViewController: Bool = {
        return self.navigationController?.viewControllers[0] == self
    }()
    
}

extension UIViewController {
    var serviceLayer: ServiceLayer {
        return ServiceLayer.sharedServiceLayer
    }
    
    func handleError(error: Error) {
        print(error)
        switch error.code {
        case 5:
            //TODO:
            let authWebView = storyboard!.instantiateViewControllerWithIdentifier("AuthWebViewController") as! AuthWebViewController
            authWebView.navigationItem.leftBarButtonItem = nil
            self.presentViewController(authWebView, animated: true, completion: nil)
            
            let alert = UIAlertController(title: "Сессия устарела", message: "Необходима повторная авторизация", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "ОК", style: .Default, handler: nil)
            let logOutAction = UIAlertAction(title: "Выйти из приложения", style: .Default, handler: { (action) in
                self.launchExitAppSequence()
            })
            alert.addAction(okAction)
            alert.addAction(logOutAction)
            
            self.presentViewController(alert, animated: true, completion: nil)
        case 14:
            //TODO:
            print("captcha")
            ToastManager.sharedInstance.presentError(error)
        case -999:
            print("loadError")
        default:
            ToastManager.sharedInstance.presentError(error)
        }
    }
    
    func launchExitAppSequence() {
        let alert = UIAlertController(title: "Вы точно хотите выйти?", message: "Все документы и папки будут удалены из приложения", preferredStyle: UIAlertControllerStyle.Alert)
        let noAction = UIAlertAction(title: "Нет", style: .Cancel, handler: nil)
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
}