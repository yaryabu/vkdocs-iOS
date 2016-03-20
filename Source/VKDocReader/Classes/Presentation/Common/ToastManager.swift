//
//  ToastManager.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 20/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit
import CRToast

class ToastManager {
    class func presentError(error: Error) {
        let responder = CRToastInteractionResponder(interactionType: CRToastInteractionType.All, automaticallyDismiss: true, block: nil)
        let options: [NSObject:AnyObject] = [
            kCRToastTextKey: error.message,
            kCRToastBackgroundColorKey: UIColor.redColor(),
            kCRToastNotificationTypeKey: CRToastType.NavigationBar.rawValue,
            kCRToastAnimationInDirectionKey: CRToastAnimationDirection.Top.rawValue,
            kCRToastAnimationOutDirectionKey: CRToastAnimationDirection.Top.rawValue,
            kCRToastTextAlignmentKey: NSTextAlignment.Center.rawValue,
            kCRToastTimeIntervalKey: 1.5,
            kCRToastInteractionRespondersKey: [responder],
            kCRToastNotificationPresentationTypeKey: CRToastPresentationType.Cover.rawValue
        ]
        CRToastManager.showNotificationWithOptions(options, completionBlock: nil)
    }
    
    class func presentInfo(message: String) {
        let responder = CRToastInteractionResponder(interactionType: CRToastInteractionType.All, automaticallyDismiss: true, block: nil)
        let options: [NSObject:AnyObject] = [
            kCRToastTextKey: message,
            kCRToastBackgroundColorKey: UIColor.greenColor(),
            kCRToastNotificationTypeKey: CRToastType.NavigationBar.rawValue,
            kCRToastAnimationInDirectionKey: CRToastAnimationDirection.Top.rawValue,
            kCRToastAnimationOutDirectionKey: CRToastAnimationDirection.Top.rawValue,
            kCRToastTextAlignmentKey: NSTextAlignment.Center.rawValue,
            kCRToastTimeIntervalKey: 1.5,
            kCRToastInteractionRespondersKey: [responder],
            kCRToastNotificationPresentationTypeKey: CRToastPresentationType.Cover.rawValue
        ]
        CRToastManager.showNotificationWithOptions(options, completionBlock: nil)
    }
}