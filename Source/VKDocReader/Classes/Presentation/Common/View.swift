//
//  View.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 05/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit

class View: UIView {
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    class func loadFromNibNamed(nibNamed: String, bundle: NSBundle? = nil) -> View? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiateWithOwner(nil, options: nil)[0] as? View
    }
    
    /// - parameter frame: frame, в который нужно презентовать View
    /// - parameter superview: superview для View, который нужно презентовать
    func presentAnimated(frame: CGRect, superview: UIView) {}
    func dismissAnimated() {}
}
