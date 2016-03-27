//
//  UIFont+VKFont.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 20/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit

//TODO: сделать нормальные имена. А-ля "vkA1Font", "vkA3Font" итд
extension UIFont {
    class func tabBarFont() -> UIFont {
        return UIFont(name: "Lucida Grande", size: 16)!
    }
    
    class func loadingPercentFont() -> UIFont {
        return UIFont(name: "Lucida Grande", size: 12)!
    }
    
    class func navigationBarFont() -> UIFont {
        return UIFont(name: "Open Sans", size: 18)!
    }
    
    class func userNameFont() -> UIFont {
        return UIFont(name: "Open Sans", size: 16)!
    }
    
    class func createFolderFieldFont() -> UIFont {
        return UIFont(name: "Open Sans", size: 16)!
    }
    
    class func defaultFont() -> UIFont {
        return UIFont(name: "Open Sans", size: 14)!
    }
    
    class func sectionHeaderFont() -> UIFont {
        return UIFont(name: "Open Sans", size: 12)!
    }
    
}
