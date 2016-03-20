//
//  SettingsLabels.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 21/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit

class Label: UILabel {
    
//    init() {
//        super.init()
//        prepareLabel()
//    }
//    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareLabel()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepareLabel()
    }
    
    func prepareLabel() {
        fatalError("no prepareLabel")
    }
    
//    class SettingsLabels: Label {
//        class func userNameLabel() -> UILabel {
//            let label = UILabel()
//            label.font = UIFont.userNameFont()
//            label.tintColor = UIColor.vkBlackColor()
//            return label
//        }
//        
//        class SettingHeaderLabel() -> Label {
//            let label = UILabel()
//            label.font = UIFont.userNameFont()
//            label.tintColor = UIColor.vkBlackColor()
//            return label
//        }
//    }
}

class UserNameLabel: Label {
    override func prepareLabel() {
        self.font = UIFont.userNameFont()
        self.tintColor = UIColor.vkBlackColor()
    }
}

class SettingHeaderLabel: Label {
    override func prepareLabel() {
        self.font = UIFont.defaultFont()
        self.tintColor = UIColor.vkWarmGreyColor()
    }
}

class NavigationBarLabel: Label {
    override func prepareLabel() {
        self.font = UIFont.navigationBarFont()
        self.tintColor = UIColor.vkBlackColor()
    }
}

class SettingLabel: Label {
    override func prepareLabel() {
        self.font = UIFont.defaultFont()
        self.tintColor = UIColor.vkBlackTwoColor()
    }
}








