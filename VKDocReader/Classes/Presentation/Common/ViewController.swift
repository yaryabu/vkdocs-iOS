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
            let alert = UIAlertController(title: "NEED_NEW_SESSION_TITLE".localized, message: "NEED_NEW_SESSION_MESSAGE".localized, preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "NEED_NEW_SESSION_OK_BUTTON".localized, style: .Default, handler: { (action) in
                let authWebViewNc = self.storyboard!.instantiateViewControllerWithIdentifier(Const.StoryboardIDs.authWebViewControllerNavigationController) as! NavigationController
                self.presentViewController(authWebViewNc, animated: true, completion: nil)
                
                })
            let logOutAction = UIAlertAction(title: "NEED_NEW_SESSION_EXIT_APP_BUTTON".localized, style: .Default, handler: { (action) in
                self.launchExitAppSequence()
            })
            alert.addAction(okAction)
            alert.addAction(logOutAction)
            
            self.presentViewController(alert, animated: true, completion: nil)
        case 14:
            ToastManager.sharedInstance.presentError(error)
            CaptchaViewController.presentCaptchaViewController(error)
        case -999:
            //Загрузка отменена (пользователем или чем-нибудь еще)
            break
        default:
            ToastManager.sharedInstance.presentError(error)
        }
    }
    
    func launchExitAppSequence() {
        let alert = UIAlertController(title: "EXIT_APP_ALERT_TITLE".localized, message: "EXIT_APP_ALERT_MESSAGE".localized, preferredStyle: UIAlertControllerStyle.Alert)
        let noAction = UIAlertAction(title: "NO".localized, style: .Cancel, handler: nil)
        let yesAction = UIAlertAction(title: "YES".localized, style: .Default) { (action) -> Void in
            Analytics.logExitApp()
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