//
//  UserSettingsSerivce.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 05/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import Foundation

class UserSettingsSerivce: Service {
    var hasLaunchedOnce: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(Const.UserDefaults.hasLaunchedOnceKey)
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: Const.UserDefaults.hasLaunchedOnceKey)
        }
    }
    
    var deleteDocumentsAfterPreview: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(Const.UserDefaults.deleteDocumentsAfterPreviewKey)
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: Const.UserDefaults.deleteDocumentsAfterPreviewKey)
        }
    }
    
    var currentDocumentsCount: Int {
        get {
            return NSUserDefaults.standardUserDefaults().integerForKey(Const.UserDefaults.currentDocumentsCount)
        }
        set {
            NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: Const.UserDefaults.currentDocumentsCount)
        }
    }
}
