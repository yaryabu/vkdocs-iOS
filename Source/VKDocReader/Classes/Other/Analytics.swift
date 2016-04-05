//
//  Analytics.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 05/04/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import Foundation

import SwiftyJSON

import Crashlytics

// поиск
// ссылка и отправить
//FIXME: вынести аналитику из share extension сюда

class Analytics {
    
    class func logUserAuthorized() {
        Answers.logCustomEventWithName(
            "User authorized",
            customAttributes: nil)
    }
    
    class func logDocumentPreview(document: Document) {
        Answers.logCustomEventWithName(
            "Document previewed",
            customAttributes: [
                "Extension":document.ext,
                "Size":Int(document.size)!
            ])
    }
    
    class func logCaptcha(successful: Bool, canceled: Bool) {
        
        var attributes: [String:AnyObject] = [:]
        if canceled {
            attributes["Action"] = "Canceled"
        } else {
            if successful {
                attributes["Action"] = "Success"
            } else {
                attributes["Action"] = "Fail"
            }
        }
        
        Answers.logCustomEventWithName(
            "Captcha",
            customAttributes: attributes)
    }
    
    class func logUserCreatedFolder(path: String) {
        
        let relativePath = path.componentsSeparatedByString(Const.Directories.fileSystemDir + "/").last!
        
        let depth = relativePath.componentsSeparatedByString("/").count - 1
        
        Answers.logCustomEventWithName(
            "Folder created",
            customAttributes: [
                "Depth":depth
            ])
    }
    
    class func logBackgroundSessionBegan(isUploading: Bool, isDownloading: Bool) {
        
        if isUploading == false && isDownloading == false {
            return
        }
        
        var attributes: [String:AnyObject] = [:]

        if isUploading {
            attributes["Action"] = "Uploading"
        }
        if isDownloading {
            attributes["Action"] = "Downloading"
        }
        
        Answers.logCustomEventWithName(
            "Background Session",
            customAttributes: attributes)
    }
    
    //MARK: - Настройки
    
    class func logCacheSize(bytes: Int) {
        Answers.logCustomEventWithName(
            "Cache size",
            customAttributes: [
                "bytes":bytes
            ])
    }
    
    class func logUseWifiOnlySetting(enabled: Bool) {
        
        var attributes: [String:AnyObject] = [:]
        
        if enabled {
            attributes["State"] = "Enabled"
        } else {
            attributes["State"] = "Disabled"
        }
        
        Answers.logCustomEventWithName(
            "Use Wi-Fi only",
            customAttributes: attributes)
    }
    
    
    class func logSaveDocsAfterPreviewSetting(enabled: Bool) {
        
        var attributes: [String:AnyObject] = [:]
        
        if enabled {
            attributes["State"] = "Enabled"
        } else {
            attributes["State"] = "Disabled"
        }
        
        Answers.logCustomEventWithName(
            "Save docs after preview",
            customAttributes: attributes)
    }
    
    class func logExitApp() {
        Answers.logCustomEventWithName(
            "User exited app",
            customAttributes: nil)
    }
    
    //MARK: - Ошибки
    
    class func logVKApiError(code: Int, message: String) {
        
        Answers.logCustomEventWithName(
            "VK API Error",
            customAttributes: [
                "Error": "CODE:\(code) MESSAGE:\(message)"
            ])
    }
    
    class func logError(error: NSError) {
        Answers.logCustomEventWithName(
            "Network NSError",
            customAttributes: [
                "Code": error.code,
                "Description": error.localizedDescription
            ])
    }
}