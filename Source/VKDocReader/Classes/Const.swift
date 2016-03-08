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
    
    struct Network {
        static let baseUrl = "https://api.vk.com/method"
        
        struct VKScopes {
            static let docsScope = "docs"
        }
        
//        struct Auth {
//            static let baseUrl = "https://oauth.vk.com/authorize"
//            static let redirectURI = "https://oauth.vk.com/blank.html"
        static let authUrlString = "https://oauth.vk.com/authorize?client_id=\(Const.Common.clientId)&display=mobile&redirect_uri=https://oauth.vk.com/blank.html&scope=\(Const.Network.VKScopes.docsScope)&response_type=token"
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

    }
    
    struct Directories {
        static let appBundleDir = NSBundle.mainBundle().bundlePath
        static let appDataDir = appBundleDir + "/VK_Documents"
        static let vaultDir = appDataDir + "/vault"
        static let fileSystemDir = appDataDir + "/fileSystem"
    }
}