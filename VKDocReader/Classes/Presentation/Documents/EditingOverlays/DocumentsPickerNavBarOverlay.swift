//
//  DocumentsPickerNavBarOverlay.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 19/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit

class DocumentsPickerNavBarOverlay: View {
    
    let titleTemplate = "EDITING_NAVBAR_OVERLAY_PICKED_TEMPLATE".localized
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = String(format: titleTemplate, 0)
        }
    }
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    @IBAction func exitButtonPressed(sender: AnyObject) {
    }
    
    override class func loadFromNibNamed(nibNamed: String, bundle: NSBundle? = nil) -> DocumentsPickerNavBarOverlay {
        return super.loadFromNibNamed(nibNamed, bundle: bundle) as! DocumentsPickerNavBarOverlay
    }
    
    override func presentAnimated(frame: CGRect, superview: UIView) {
        let originalFrame = CGRect(
            x: frame.origin.x,
            y: frame.origin.y - frame.height,
            width: frame.width,
            height: frame.height
        )
        self.frame = originalFrame
        superview.addSubview(self)
        
        UIView.animateWithDuration(0.3) { () -> Void in
            self.frame = frame
        }
    }
    
    override func dismissAnimated() {
        let newFrame = CGRect(
            x: frame.origin.x,
            y: frame.origin.y - frame.height - UIApplication.sharedApplication().statusBarFrame.height,
            width: frame.width,
            height: frame.height
        )
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.frame = newFrame
            }) { (result) -> Void in
                self.removeFromSuperview()
        }
    }
    
}
