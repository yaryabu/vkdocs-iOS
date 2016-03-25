//
//  SettingsLabels.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 21/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit

//TODO: сделать нормальные имена. А-ля "vkA1Label", "vkA3Label" итд
class Label: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareLabel()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepareLabel()
    }
    
    func prepareLabel() {
        fatalError("prepareLabel not implemented")
    }

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








