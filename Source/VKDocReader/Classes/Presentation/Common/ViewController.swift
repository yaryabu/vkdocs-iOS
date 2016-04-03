//
//  ViewController.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 05/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit
import RealmSwift

/**
 Базовый класс для всех VC в МП (за исключением TabBar, NavBar итд)
 */
class ViewController: UIViewController {
    /**
     Является ли VC первым в стаке для своего navigationController
    */
    lazy var isRootViewController: Bool = {
        return self.navigationController?.viewControllers[0] == self
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.errorOccured(_:)), name: Const.Notifications.errorOccured, object: nil)
    }
    
    
    func errorOccured(notification: NSNotification) {
        if let wrapper = notification.object as? Wrapper<Error> {
            handleError(wrapper.wrappedValue)
        }
    }
    
}

extension UIViewController {
    var serviceLayer: ServiceLayer {
        return ServiceLayer.sharedServiceLayer
    }
    
    func handleError(error: Error) {
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
            //TODO: капча
            ToastManager.sharedInstance.presentError(error)
        case -999:
            //Загрузка отменена (пользователем или чем-нибудь еще)
            break
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
            Bash.rm(Const.Directories.fileSystemDir)
            Bash.mkdir(Const.Directories.fileSystemDir)
            Bash.rm(Const.Directories.vaultDir)
            Bash.mkdir(Const.Directories.vaultDir)
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.chooseInitialViewCotroller()
        }
        alert.addAction(noAction)
        alert.addAction(yesAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
}