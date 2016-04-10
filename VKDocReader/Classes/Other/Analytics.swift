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
    
    class func logSearchQuery(query: String) {
        Answers.logCustomEventWithName(
            "Search",
            customAttributes: [
                "Query":query
            ])
    }
    
    class func logDocumentShareOpened() {
        Answers.logCustomEventWithName(
            "Document share opened",
            customAttributes: nil)
    }
    
    class func logDocumentLinkCopied() {
        Answers.logCustomEventWithName(
            "Document link copied",
            customAttributes: nil)
    }
    
    class func logDocumentsCount(count: Int) {
        Answers.logCustomEventWithName(
            "Documents count",
            customAttributes: [
                "Count":count
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
                "Code": String(code),
                "Message": message
            ])
    }
    
    class func logError(error: NSError) {
        Answers.logCustomEventWithName(
            "Network NSError",
            customAttributes: [
                "Code": String(error.code),
                "Description": error.localizedDescription
            ])
    }
    
    //MARK: - Share Extension
    
    class func logShareExtensionInfo(fileExtensions: [String]) {
        
        for ext in fileExtensions {
            Answers.logCustomEventWithName(
                "Share extension",
                customAttributes: [
                    "File extension":ext
                ])
        }
        Answers.logCustomEventWithName(
            "Share extension",
            customAttributes: [
                "Count": fileExtensions.count
            ])
        
    }
    
}