//
//  Window.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 20/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit

class Window: UIWindow {
    
    var timer: NSTimer!
    var errorViewFrame: CGRect!
    var errorStack: [Error] = []

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        timer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "checkErrorStack", userInfo: nil, repeats: true)
        timer.fire()
        
        let storyboard = UIStoryboard(name: Const.Common.mainStoryboardName, bundle: nil)
        let navController = storyboard.instantiateViewControllerWithIdentifier(Const.StoryboardIDs.moveCopyViewControllerNavigationController) as! NavigationController
        let navBarFrame = navController.navigationBar.frame
        errorViewFrame = CGRect(
            x: 0,
            y: 0,
            width: navBarFrame.width,
            height: navBarFrame.height + UIApplication.sharedApplication().statusBarFrame.height
        )
//        errorViewFrame = CGRectOffset(navBarFrame, 0, UIApplication.sharedApplication().statusBarFrame.height)

    }
    
    func showError(error: Error) {
//        errorStack.append(error)
//        let window = UIWindow(frame: errorViewFrame)
//        let view = UIView(frame: errorViewFrame)
////        window.frame = errorViewFrame
////        view.frame = errorViewFrame
//        let vc = UIViewController()
//        vc.view.addSubview(view)
//        
//        view.backgroundColor = UIColor.redColor()
        
//        window.rootViewController = vc
//        window.windowLevel = UIWindowLevelStatusBar + 1
//        addSubview(view)
        
//        window.hidden = false
    }
    
    func checkErrorStack() {
        if errorStack.count > 0 {
            showError(errorStack.first!)
        }
    }
    
}