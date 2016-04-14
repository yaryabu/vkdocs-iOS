//
//  DocumentsPickerTabBarOverlay.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 19/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit

class DocumentsPickerTabBarOverlay: View {
    
    @IBOutlet weak var deleteButton: UIButton! {
        didSet {
            deleteButton.setTitle("EDITING_TAB_OVERLAY_DELETE".localized, forState: UIControlState.Normal)
        }
    }
    @IBOutlet weak var moveButton: UIButton! {
        didSet {
            moveButton.setTitle("EDITING_TAB_OVERLAY_MOVE".localized, forState: UIControlState.Normal)
        }
    }
    @IBOutlet weak var copyButton: UIButton! {
        didSet {
            copyButton.setTitle("EDITING_TAB_OVERLAY_COPY".localized, forState: UIControlState.Normal)
        }
    }
    
    
    override class func loadFromNibNamed(nibNamed: String, bundle: NSBundle? = nil) -> DocumentsPickerTabBarOverlay {
        return super.loadFromNibNamed(nibNamed, bundle: bundle) as! DocumentsPickerTabBarOverlay
    }
    
    override func presentAnimated(frame: CGRect, superview: UIView) {
        let originalFrame = CGRect(
            x: frame.origin.x,
            y: frame.origin.y + frame.height,
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
    
    func changeButtonsState(itemsSelected: Int, isRootViewController: Bool) {
        if itemsSelected > 0 {
            deleteButton.enabled = true
            copyButton.enabled = true
            moveButton.enabled = !isRootViewController
        } else {
            deleteButton.enabled = false
            copyButton.enabled = false
            moveButton.enabled = false
        }
    }
}
