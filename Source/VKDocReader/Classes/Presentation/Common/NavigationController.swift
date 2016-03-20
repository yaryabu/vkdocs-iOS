//
//  NavigationController.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 11/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var navigationBarFrameHidden: Bool {
        get {
            return self.navigationBar.frame.origin.y < 0
        }
    }
    
    var navBarAndStatusBarHeight: CGFloat {
        get {
            return self.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.height
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.userInteractionEnabled = true
        self.view.userInteractionEnabled = true
    }
    
    func hideNavigationBarFrame(animationDuration: Double?, additionalAnimations: (() -> ())?) {
        if self.navigationBarFrameHidden {
            return
        }
        UIView.animateWithDuration(animationDuration ?? 0.3) { () -> Void in
            self.navigationBar.frame = CGRect(
                x: 0,
                y: -self.navigationBar.frame.height,
                width: self.navigationBar.frame.width,
                height: self.navigationBar.frame.height
            )
            additionalAnimations?()
        }
    }
    
    func showNavigationBarFrame(animationDuration: Double?, additionalAnimations: (() -> ())?) {
        if self.navigationBarFrameHidden == false {
            return
        }
        UIView.animateWithDuration(animationDuration ?? 0.3) { () -> Void in
            self.navigationBar.frame = CGRect(
                x: 0,
                y: UIApplication.sharedApplication().statusBarFrame.height,
                width: self.navigationBar.frame.width,
                height: self.navigationBar.frame.height
            )
            additionalAnimations?()
        }
    }
    
}