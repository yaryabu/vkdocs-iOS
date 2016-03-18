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

    override func viewDidLoad() {
        super.viewDidLoad()
        print("SIZE", Bash.du(Const.Directories.vaultDir))
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
                    print(error)
            })
            }) { (error) -> Void in
                print(error)
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
