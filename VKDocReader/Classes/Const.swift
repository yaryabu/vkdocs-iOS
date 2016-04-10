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
        //FIXME: вынести куда-нибудь в Keys.swift или типа того
        static let clientId = "5295261"
        static let bundleIdentifier = NSBundle.mainBundle().bundleIdentifier!
        static let mainStoryboardName = "Main"
        static let errorDomain = bundleIdentifier + ".error"
        //рандомная строка, которая добавляется ко всем папкам для документов, чтобы
        //не было конфликтов с пользовательскими папками
        static let directoryConflictHelper = ".CONFLICT_CONSTANT"
    }
    
    struct Notifications {
        static let statusBarTouched = Common.bundleIdentifier + ".statusBarTouchedNotification"
        static let cellButtonPressed = Common.bundleIdentifier + ".UserDocsTableViewCellButtonPressedNotification"
        
        static let uploadProgress = Common.bundleIdentifier + ".uploadProgressNotification"
        static let uploadComplete = Common.bundleIdentifier + ".uploadCompleteNotification"
        
        static let errorOccured = Common.bundleIdentifier + ".errorOccuredNotification"
    }
    
    struct Network {
        static let baseUrl = "https://api.vk.com/method"
        static let apiVersion = "5.50"
        
        struct VKScopes {
            static let docsScope = "docs"
            static let offlineScope = "offline"
            static let appScope = "\(docsScope),\(offlineScope)"
        }
        
        static let authUrlString = "https://oauth.vk.com/authorize?client_id=\(Const.Common.clientId)&display=mobile&redirect_uri=https://oauth.vk.com/blank.html&scope=\(Const.Network.VKScopes.appScope)&response_type=token"
    }
    
    struct StoryboardIDs {
        static let authViewController = "AuthViewController"
        static let authWebViewController = "AuthWebViewController"
        static let authWebViewControllerNavigationController = "AuthWebViewControllerNavigationController"
        
        static let tabBarController = "TabBarController"
        
        static let userDocsTableViewController = "UserDocsTableViewController"
        static let userDocsTableViewControllerNavigationController = "UserDocsTableViewControllerNavigationController"
        
        static let moveCopyViewController = "MoveCopyViewController"
        static let moveCopyViewControllerNavigationController = "MoveCopyViewControllerNavigationController"
        
        static let editViewController = "EditViewController"
        static let editViewControllerNavigationController = "EditViewControllerNavigationController"
        
        static let captchaViewController = "CaptchaViewController"

    }
    
    struct StoryboardSegues {
        static let logInButtonPressed = "logInButtonPressed"
        static let logInSuccess = "logInSuccess"
        static let previewDocument = "previewDocument"
        static let createFolder = "createFolder"
    }
    
    struct Keychain {
        static let serviceName = Const.Common.bundleIdentifier + ".keychainService"
        static let sharedAccountName = serviceName + ".sharedAccount"
    }
    
    struct UserDefaults {
        
        static let appGroupId = "group.ru.yaryabu.VKDocs"
        static let userToken = "User access token"
        
        static let userIdKey = "VK UserID"
        static let hasLaunchedOnceKey = "App has launched once"
        static let deleteDocumentsAfterPreviewKey = "Delete documents after preview"
        static let currentDocumentsCount = "Current documents count"
        static let useWifiOnly = "Use Wi-Fi only"
        
        static let shareExtensionDocumentsExtensions = "Share extension documents extensions"

    }
    
    struct Directories {
        static let appDocumentsDir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first!
        static let vkDocumentsDir = appDocumentsDir + "/VK_Documents"
        static let vaultDir = vkDocumentsDir + "/vault"
        static let fileSystemDir = vkDocumentsDir + "/fileSystem"
    }
}