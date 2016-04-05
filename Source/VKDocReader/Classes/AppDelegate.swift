//
//  AppDelegate.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 05/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit

import SSKeychain
import RealmSwift

import Fabric
import Crashlytics


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Fabric.with([Crashlytics.self])
        
        //TODO: при запуске надо бы почистить tmp
        
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
    
    func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: () -> Void) {
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        Analytics.logBackgroundSessionBegan(
            LoadTaskManager.sharedManager.isUploadingNow,
            isDownloading: LoadTaskManager.sharedManager.downloadRequestPool.count > 0)
    }

    func chooseInitialViewCotroller() {
        let storyboard = UIStoryboard(name: Const.Common.mainStoryboardName, bundle: NSBundle.mainBundle())
        if (ServiceLayer.sharedServiceLayer.authService.token != nil) {
            self.window?.rootViewController = storyboard.instantiateViewControllerWithIdentifier(Const.StoryboardIDs.tabBarController)
        } else {
            self.window?.rootViewController = storyboard.instantiateViewControllerWithIdentifier(Const.StoryboardIDs.authViewController)
        }
        window?.makeKeyAndVisible()
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        let location = event!.allTouches()!.first!.locationInView(self.window)
        if CGRectContainsPoint(UIApplication.sharedApplication().statusBarFrame, location) {
            NSNotificationCenter.defaultCenter().postNotificationName(Const.Notifications.statusBarTouched, object: nil)
        }
    }
    
}

