//
//  AppDelegate.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 05/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit

//import SSKeychain
import RealmSwift
import VK_ios_sdk

import Fabric
import Crashlytics


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, VKSdkDelegate, VKSdkUIDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Fabric.with([Crashlytics.self])
        
        // VK пытается присунуть свои странные токены в cookies
        // если эти токены протухают, то документы становится невозможно просматривать
        NSHTTPCookieStorage.sharedHTTPCookieStorage().cookieAcceptPolicy = NSHTTPCookieAcceptPolicy.Never
        
        let vkSdk = VKSdk.initializeWithAppId(Const.Common.clientId)
        vkSdk.registerDelegate(self)
        vkSdk.uiDelegate = self
        
        Dispatch.defaultQueue { 
            for file in Bash.ls(NSTemporaryDirectory()) {
                if file.containsString(Const.Common.directoryConflictHelper) {
                    Bash.rm(NSTemporaryDirectory() + file)
                }
            }
        }
        
        let defaults = NSUserDefaults(suiteName: Const.UserDefaults.appGroupId)
        defaults?.synchronize()
        if let extensions = defaults?.stringArrayForKey(Const.UserDefaults.shareExtensionDocumentsExtensions) {
            Analytics.logShareExtensionInfo(extensions)
            defaults?.removeObjectForKey(Const.UserDefaults.shareExtensionDocumentsExtensions)
        }
        
        
        if Bash.fileExists(Const.Directories.vaultDir) == false {
            Bash.mkdir(Const.Directories.vaultDir)
        }
        if Bash.fileExists(Const.Directories.fileSystemDir) == false {
            Bash.mkdir(Const.Directories.fileSystemDir)
        }

        Bash.cd(Const.Directories.fileSystemDir)
        chooseInitialViewCotroller()
        
        return true
    }
    
    func vkSdkAccessAuthorizationFinishedWithResult(result: VKAuthorizationResult!) {
        if result.error == nil {
            ServiceLayer.sharedServiceLayer.authService.saveAuthData(result.token)
            Analytics.logUserAuthorized()
            self.chooseInitialViewCotroller()
        } else {
            // игнорируем ошибки, потому что от VK sdk приходят странные вещи
        }
    }
    
    func vkSdkUserAuthorizationFailed() {}
    
    func vkSdkShouldPresentViewController(controller: UIViewController!) {
        window!.rootViewController!.presentViewController(controller, animated: true, completion: nil)
    }
    
    func vkSdkNeedCaptchaEnter(captchaError: VKError!) {}
    
    
    func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: () -> Void) {}
    
    @available(iOS 9.0, *)
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        VKSdk.processOpenURL(url, fromApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as! String)
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        VKSdk.processOpenURL(url, fromApplication: sourceApplication)
        return true
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        Analytics.logBackgroundSessionBegan(
            LoadTaskManager.sharedManager.isUploadingNow,
            isDownloading: LoadTaskManager.sharedManager.downloadRequestPool.count > 0)
    }

    func chooseInitialViewCotroller() {
        var newRootVC: UIViewController?
        
        let storyboard = UIStoryboard(name: Const.Common.mainStoryboardName, bundle: NSBundle.mainBundle())
        
        if ServiceLayer.sharedServiceLayer.authService.token != nil &&
            window?.rootViewController as? AuthViewController != nil {
            newRootVC = storyboard.instantiateViewControllerWithIdentifier(Const.StoryboardIDs.tabBarController)
        } else {
            if window?.rootViewController as? TabBarController != nil {
                newRootVC = storyboard.instantiateViewControllerWithIdentifier(Const.StoryboardIDs.authViewController)
            }
            
        }
        
        if let newRootVC = newRootVC {
            let previousViewController = window?.rootViewController
            
            let tr = CATransition()
            tr.duration = 0.5
            tr.type = "flip"
            tr.subtype = kCATransitionFromRight
            window?.layer.addAnimation(tr, forKey: kCATransition)
            
            window?.rootViewController = newRootVC
            
            UIView.animateWithDuration(CATransaction.animationDuration()) {
                newRootVC.setNeedsStatusBarAppearanceUpdate()
            }
            
            if let previousViewController = previousViewController {
                previousViewController.dismissViewControllerAnimated(false) {
                    previousViewController.view.removeFromSuperview()
                }
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        let location = event!.allTouches()!.first!.locationInView(self.window)
        if CGRectContainsPoint(UIApplication.sharedApplication().statusBarFrame, location) {
            NSNotificationCenter.defaultCenter().postNotificationName(Const.Notifications.statusBarTouched, object: nil)
        }
    }
    
}


