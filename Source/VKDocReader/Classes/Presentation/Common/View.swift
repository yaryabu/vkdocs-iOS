//
//  View.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 05/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit

class View: UIView {
    class func loadFromNibNamed(nibNamed: String, bundle: NSBundle? = nil) -> View? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiateWithOwner(nil, options: nil)[0] as? View
    }
    func presentAnimated(frame: CGRect, view: UIView) {}
    func dismissAnimated() {}
}
