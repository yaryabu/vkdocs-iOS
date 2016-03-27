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
        //
        if Bash.fileExists(Const.Directories.vaultDir) == false {
            Bash.mkdir(Const.Directories.vaultDir)
        }
        if Bash.fileExists(Const.Directories.fileSystemDir) == false {
            Bash.mkdir(Const.Directories.fileSystemDir)
        }
        //пока что не нужно особых действий при первом запуске
//        if ServiceLayer.sharedServiceLayer.userSettingsService.hasLaunchedOnce == false {

            SSKeychain.setAccessibilityType(kSecAttrAccessibleAlwaysThisDeviceOnly)
//            ServiceLayer.sharedServiceLayer.userSettingsService.hasLaunchedOnce = true
//        }
        Bash.cd(Const.Directories.fileSystemDir)
        self.chooseInitialViewCotroller()
        
        return true
    }
    
    func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: () -> Void) {
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

