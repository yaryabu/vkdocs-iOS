//
//  Const.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 05/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import Foundation

struct Const {
    struct Common {
        static let clientId = "5295261"
        static let bundleIdentifier = NSBundle.mainBundle().bundleIdentifier!
        static let mainStoryboardName = "Main"
    }
    
    struct Notifications {
        static let statusBarTouched = "statusBarTouchedNotification"
    }
    
    struct Network {
        static let baseUrl = "https://api.vk.com/method"
        static let apiVersion = "5.50"
        
        struct VKScopes {
            static let docsScope = "docs"
            static let offlineScope = "offline"
            static let appScope = "\(docsScope),\(offlineScope)"
        }
        
//        struct Auth {
//            static let baseUrl = "https://oauth.vk.com/authorize"
//            static let redirectURI = "https://oauth.vk.com/blank.html"
        static let authUrlString = "https://oauth.vk.com/authorize?client_id=\(Const.Common.clientId)&display=mobile&redirect_uri=https://oauth.vk.com/blank.html&scope=\(Const.Network.VKScopes.appScope)&response_type=token"
//        }
    }
    
    struct StoryboardIDs {
        static let authViewController = "AuthViewController"
        static let tabBarController = "TabBarController"
//        static let sidebarViewController = "SidebarViewController"
        static let userDocsTableViewController = "UserDocsTableViewController"
        static let UserDocsTableViewControllerNavigationController = "UserDocsTableViewControllerNavigationController"
    }
    
    struct StoryboardSegues {
        static let logInButtonPressed = "logInButtonPressed"
        static let logInSuccess = "logInSuccess"
        static let previewDocument = "previewDocument"
    }
    
    struct Keychain {
        static let serviceName = Const.Common.bundleIdentifier + ".keychainService"
        static let sharedAccountName = serviceName + ".sharedAccount"
    }
    
    struct UserDefaults {
        static let userIdKey = "VK UserID"
        static let hasLaunchedOnceKey = "App has launched once"
        static let deleteDocumentsAfterPreviewKey = "Delete documents after preview"
        static let currentDocumentsCount = "Current documents count"
        static let useWifiOnly = "Use Wi-Fi only"

    }
    
    struct Directories {
        static let appDocumentsDir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first!
        static let vkDocumentsDir = appDocumentsDir + "/VK_Documents"
        static let vaultDir = vkDocumentsDir + "/vault"
        static let fileSystemDir = vkDocumentsDir + "/fileSystem"
    }
}