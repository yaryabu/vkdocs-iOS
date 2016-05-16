//
//  Const.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 05/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit

struct Const {
    struct Common {
        //FIXME: вынести куда-нибудь в Keys.swift или типа того
        static let clientId = "5295261"
        static let bundleIdentifier = NSBundle.mainBundle().bundleIdentifier!
        static let appVersion = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        static let appBuildNumber = NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey as String) as! String
        static let fullVersion = "\(appVersion) (\(appBuildNumber))"
        static let mainStoryboardName = "Main"
        static let errorDomain = bundleIdentifier + ".error"
        //рандомная строка, которая добавляется ко всем папкам для документов, чтобы
        //не было конфликтов с пользовательскими папками
        static let directoryConflictHelper = ".CONFLICT_CONSTANT"
    }
    
    struct DeviceInfo {
        static let modelName = getModelName()
        static let systemVersion = UIDevice.currentDevice().systemVersion
        static let fullInfo = "\(modelName) (iOS \(systemVersion))"
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
            static let vkSdkAppScope = [docsScope, offlineScope]
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
        static let tmp = NSTemporaryDirectory() + Common.bundleIdentifier
    }
}


func getModelName() -> String {
    //    var modelName: String {
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let identifier = machineMirror.children.reduce("") { identifier, element in
        guard let value = element.value as? Int8 where value != 0 else { return identifier }
        return identifier + String(UnicodeScalar(UInt8(value)))
    }
    
    switch identifier {
    case "iPod5,1":                                 return "iPod Touch 5"
    case "iPod7,1":                                 return "iPod Touch 6"
    case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
    case "iPhone4,1":                               return "iPhone 4s"
    case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
    case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
    case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
    case "iPhone7,2":                               return "iPhone 6"
    case "iPhone7,1":                               return "iPhone 6 Plus"
    case "iPhone8,1":                               return "iPhone 6s"
    case "iPhone8,2":                               return "iPhone 6s Plus"
    case "iPhone8,4":                               return "iPhone SE"
    case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
    case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
    case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
    case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
    case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
    case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
    case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
    case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
    case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
    case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8":return "iPad Pro"
    case "AppleTV5,3":                              return "Apple TV"
    case "i386", "x86_64":                          return "Simulator"
    default:                                        return identifier
    }
}