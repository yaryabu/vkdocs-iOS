//
//  DocumentsPickerTabBarOverlay.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 19/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit

class DocumentsPickerTabBarOverlay: View {
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var moveButton: UIButton!
    @IBOutlet weak var copyButton: UIButton!
    
    
    override class func loadFromNibNamed(nibNamed: String, bundle: NSBundle? = nil) -> DocumentsPickerTabBarOverlay {
        return super.loadFromNibNamed(nibNamed, bundle: bundle) as! DocumentsPickerTabBarOverlay
    }
    
    override func presentAnimated(frame: CGRect) {
        let newFrame = CGRect(
            x: frame.origin.x,
            y: frame.origin.y + frame.height,
            width: frame.width,
            height: frame.height
        )
        self.frame = newFrame
        UIApplication.sharedApplication().keyWindow!.addSubview(self)
        UIView.animateWithDuration(0.3) { () -> Void in
            self.frame = frame
        }
    }
    
    override func dismissAnimated() {
        let newFrame = CGRect(
            x: frame.origin.x,
            y: frame.origin.y + frame.height,
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
