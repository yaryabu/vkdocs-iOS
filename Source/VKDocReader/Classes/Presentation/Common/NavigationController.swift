//
//  NavigationController.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 11/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    
    lazy var uploadProgressBarView: UIProgressView = {
        let progressView = UIProgressView(frame: CGRect(
            x: 0,
            y: self.navigationBar.frame.origin.y + self.navigationBar.frame.height - 2,
            width: self.navigationBar.frame.width,
            height: 2
        ))
        progressView.progressTintColor = UIColor.vkEmeraldColor()
        progressView.trackTintColor = UIColor.clearColor()
        progressView.backgroundColor = UIColor.clearColor()
        progressView.tintColor = UIColor.clearColor()
        progressView.progress = 0.0
        
        return progressView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NavigationController.uploadProgressChanged(_:)), name: Const.Notifications.uploadProgress, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NavigationController.uploadComplete(_:)), name: Const.Notifications.uploadComplete, object: nil)
        
        navigationBar.addSubview(uploadProgressBarView)
        
        UINavigationBar.appearance().titleTextAttributes = [
            NSFontAttributeName: UIFont.navigationBarFont(),
            NSForegroundColorAttributeName: UIColor.vkBlackColor()
        ]
        UINavigationBar.appearance().backIndicatorImage = UIImage(named: "back_button")
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage(named: "back_button")
        UINavigationBar.appearance().tintColor = UIColor.vkBlackColor()
        
        //в связке с "Status bar style" в Info.plist помогает убрать дивайдер под навбаром
        navigationBar.barStyle = .Black
        navigationBar.barTintColor = UIColor.vkWhiteColor()
    }
    
    
    func uploadProgressChanged(notification: NSNotification) {
        let percent = notification.object as! Float
        uploadProgressBarView.progress = percent
    }
    
    func uploadComplete(notification: NSNotification) {
        uploadProgressBarView.progress = 0.0
    }

    
}