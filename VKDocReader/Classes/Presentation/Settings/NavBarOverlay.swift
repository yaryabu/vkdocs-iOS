//
//  NavBarOverlay.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 06/04/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit

class NavBarOverlay: View {
    override class func loadFromNibNamed(nibNamed: String, bundle: NSBundle? = nil) -> NavBarOverlay {
        return super.loadFromNibNamed(nibNamed, bundle: bundle) as! NavBarOverlay
    }
    @IBOutlet weak var userAvatarImageView: UIImageView! {
        didSet {
            userAvatarImageView.layer.masksToBounds = true
            userAvatarImageView.layer.cornerRadius = 15
        }
    }
    
    @IBOutlet weak var usernameLabel: UserNameLabel!
//    let owner: SettingsViewController
//    let user: User
    @IBOutlet weak var exitAppButton: UIButton!
}