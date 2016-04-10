//
//  TabBarController.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 16/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit
import RealmSwift

class TabBarController: UITabBarController {
    
    lazy var firstTabSelectedViewFrame: CGRect = {
        return CGRect(
            x: 0,
            y: 0,
            width: self.tabBar.frame.width/2,
            height: 2
        )
    }()
    
    lazy var secondTabSelectedViewFrame: CGRect = {
        CGRect(
            x: self.tabBar.frame.width/2,
            y: 0,
            width: self.tabBar.frame.width/2,
            height: 2
        )
    }()
    
    lazy var selectedTabIndicatorView: UIView = {
        let view = UIView(frame: self.firstTabSelectedViewFrame)
        view.backgroundColor = UIColor.vkDuskBlueColor()
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.items![0].title = "FIRST_TAB_TITLE".localized
        tabBar.items![1].title = "SECOND_TAB_TITLE".localized
        
        loadUserData()
        
        tabBar.addSubview(selectedTabIndicatorView)

        UITabBarItem.appearance().setTitleTextAttributes([
            NSFontAttributeName: UIFont.tabBarFont(),
            NSForegroundColorAttributeName: UIColor.vkBlackColor()
            ],
            forState: UIControlState.Normal
        )
        UITabBarItem.appearance().setTitleTextAttributes([
            NSFontAttributeName: UIFont.tabBarFont(),
            NSForegroundColorAttributeName: UIColor.vkDuskBlueColor()
            ],
            forState: UIControlState.Selected
        )
        UITabBarItem.appearance().titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -15)
        tabBar.backgroundImage = UIImage()
        tabBar.backgroundColor = UIColor.vkWhiteColor()
    }
    
    override func viewWillLayoutSubviews() {
        let screenFrame = UIApplication.sharedApplication().keyWindow!.frame
        let tabBarFrame = CGRect(
            x: 0,
            y: screenFrame.height - 48,
            width: screenFrame.width,
            height: 48
        )
        tabBar.frame = tabBarFrame
    }
    
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        if tabBar.items!.indexOf(item) == 0 {
            UIView.animateWithDuration(0.3, animations: { 
                self.selectedTabIndicatorView.frame = self.firstTabSelectedViewFrame
            })
        } else {
            UIView.animateWithDuration(0.3, animations: {
                self.selectedTabIndicatorView.frame = self.secondTabSelectedViewFrame
            })
        }
    }
    
    func loadUserData() {
        self.serviceLayer.userService.getUserInfo({ (user) -> Void in
            let realm = try! Realm()
            
            if let cachedUser = realm.objects(User).first {
                if cachedUser == user && cachedUser.photoData != nil {
                    return
                }
            }
            
            try! realm.write({ () -> Void in
                realm.add(user, update: true)
            })
            
            self.serviceLayer.userService.getUserAvatarData(user, completion: { (data) -> Void in
                try! realm.write({ () -> Void in
                    user.photoData = data
                })
                }, failure: { (error) -> Void in
                    self.handleError(error)
            })
        }) { (error) -> Void in
            self.handleError(error)
        }
    }
}

