//
//  AppDelegate.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 05/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit

import SSKeychain

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        if Bash.fileExists(Const.Directories.vaultDir, isDirectory: true) == false {
            Bash.mkdir(Const.Directories.vaultDir)
        }
        if Bash.fileExists(Const.Directories.fileSystemDir, isDirectory: true) == false {
            Bash.mkdir(Const.Directories.fileSystemDir)
        }
//        if ServiceLayer.sharedServiceLayer.userSettingsService.hasLaunchedOnce == false {
            print("firstLaunch")

            SSKeychain.setAccessibilityType(kSecAttrAccessibleAlwaysThisDeviceOnly)
            ServiceLayer.sharedServiceLayer.userSettingsService.hasLaunchedOnce = true
//        }
        Bash.cd(Const.Directories.appBundleDir)
        self.chooseInitialViewCotroller()
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func chooseInitialViewCotroller() {
        if (ServiceLayer.sharedServiceLayer.authService.token != nil) {
            let storyboard = UIStoryboard.init(name: Const.Common.mainStoryboardName, bundle: NSBundle.mainBundle())
            self.window?.rootViewController = storyboard.instantiateViewControllerWithIdentifier(Const.StoryboardIDs.tabBarController)
            self.window?.makeKeyAndVisible()
        }
        // ViewController авторизации изначально initial в Main.storyboard
        
    }
}

