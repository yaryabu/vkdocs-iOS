//
//  ToastManager.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 20/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit
import CRToast

/**
 Менеджер нотификаций на навбаре.
 */
class ToastManager {
    static let sharedInstance = ToastManager()
    private init() {}
    
    private var latestToast: (message: String, toastTimestamp: NSTimeInterval) = ("", NSDate(timeIntervalSince1970: 1).timeIntervalSince1970)
    
    /**
     Презентует error.message в красном цвете
    */
    func presentError(error: Error, duration: Double = 1.5) {
        presentToast(error.message, color: UIColor.vkGrapefruitColor(), duration: duration)
    }
    
    /**
     Презентует message в зеленом цвете
    */
    func presentInfo(message: String, duration: Double = 1.5) {
        presentToast(message, color: UIColor.vkEmeraldColor(), duration: duration)
    }
    
    private func presentToast(message: String, color: UIColor, duration: Double) {
        if shouldShowToast(message) {
            addLatestToast(message)
        } else {
            return
        }
        
        let responder = CRToastInteractionResponder(interactionType: CRToastInteractionType.All, automaticallyDismiss: true, block: nil)
        let options: [NSObject:AnyObject] = [
            kCRToastTextKey: message,
            kCRToastBackgroundColorKey: color,
            kCRToastNotificationTypeKey: CRToastType.NavigationBar.rawValue,
            kCRToastAnimationInDirectionKey: CRToastAnimationDirection.Top.rawValue,
            kCRToastAnimationOutDirectionKey: CRToastAnimationDirection.Top.rawValue,
            kCRToastTextAlignmentKey: NSTextAlignment.Center.rawValue,
            kCRToastTimeIntervalKey: duration,
            kCRToastInteractionRespondersKey: [responder],
            kCRToastNotificationPresentationTypeKey: CRToastPresentationType.Cover.rawValue,
            kCRToastFontKey: UIFont.createFolderFieldFont(),
            kCRToastTextColorKey: UIColor.vkWhiteColor(),
            kCRToastAnimationInTimeIntervalKey: 0.25,
            kCRToastAnimationOutTimeIntervalKey: 0.25
        ]
        CRToastManager.showNotificationWithOptions(options, completionBlock: nil)
    }
    
    private func shouldShowToast(toastMessage: String) -> Bool {
        if toastMessage == latestToast.message {
            let currentTimeStamp = NSDate().timeIntervalSince1970
            if currentTimeStamp - latestToast.toastTimestamp < 2.0 {
                return false
            }
        }
        return true
        
    }
    
    private func addLatestToast(toastMessage: String) {
        latestToast = (toastMessage, NSDate().timeIntervalSince1970)
    }
}