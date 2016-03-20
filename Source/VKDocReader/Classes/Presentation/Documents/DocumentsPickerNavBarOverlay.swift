//
//  DocumentsPickerNavBarOverlay.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 19/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit

class DocumentsPickerNavBarOverlay: View {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var exitButton: UIButton!
    
    @IBAction func exitButtonPressed(sender: AnyObject) {
    }
    
    override class func loadFromNibNamed(nibNamed: String, bundle: NSBundle? = nil) -> DocumentsPickerNavBarOverlay {
        return super.loadFromNibNamed(nibNamed, bundle: bundle) as! DocumentsPickerNavBarOverlay
    }
    
    override func presentAnimated(frame: CGRect, view: UIView) {
        let newFrame = CGRect(
            x: frame.origin.x,
            y: frame.origin.y - frame.height,
            width: frame.width,
            height: frame.height
        )
        self.frame = newFrame
        view.addSubview(self)
        
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
