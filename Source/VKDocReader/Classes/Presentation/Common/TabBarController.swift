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
    
    let firstTabSelectedView = UIView()
    let secondTabSelectedView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.serviceLayer.userService.getUserInfo({ (user) -> Void in
            let realm = try! Realm()
            
            if let cachedUser = realm.objects(User).first {
                if cachedUser == user {
                    return
                }
            }
            
            self.serviceLayer.userService.getUserAvatarData(user, completion: { (data) -> Void in
                user.photoData = data
                try! realm.write({ () -> Void in
                    realm.add(user, update: true)
                })
                }, failure: { (error) -> Void in
                    self.handleError(error)
            })
            }) { (error) -> Void in
                self.handleError(error)
        }
        
        firstTabSelectedView.frame = CGRect(
            x: 0,
            y: 0,
            width: tabBar.frame.width/2,
            height: 2
        )
        secondTabSelectedView.frame = CGRect(
            x: tabBar.frame.width/2,
            y: 0,
            width: tabBar.frame.width/2,
            height: 2
        )
        firstTabSelectedView.backgroundColor = UIColor.vkDuskBlueColor()
        secondTabSelectedView.backgroundColor = UIColor.vkDuskBlueColor()
        
        tabBar.addSubview(firstTabSelectedView)

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
            secondTabSelectedView.removeFromSuperview()
            tabBar.addSubview(firstTabSelectedView)
        } else {
            firstTabSelectedView.removeFromSuperview()
            tabBar.addSubview(secondTabSelectedView)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

