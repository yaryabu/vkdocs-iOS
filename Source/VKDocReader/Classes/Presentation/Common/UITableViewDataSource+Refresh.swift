//
//  UITableViewDataSource+Refresh.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 18/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit

protocol DataSource: UITableViewDataSource {
    func refresh(refreshEnded: () -> Void, refreshFailed: (error: Error) -> Void)
    func document(indexPath: NSIndexPath) -> Document
    func updateCache()
}

//extension UIAlertController {
//    func closeOnTap(parentVC: ViewController) {
////        parentVC.addChildViewController(self)
//        let gs = UITapGestureRecognizer(target: self, action: "tap:")
//        
//        if preferredStyle == UIAlertControllerStyle.ActionSheet {
//            parentVC.view.userInteractionEnabled = true
//            parentVC.view.addGestureRecognizer(gs)
//        }
//    }
//    
//    func tap(sender: UITapGestureRecognizer) {
//        dismissViewControllerAnimated(true, completion: nil)
//    }
//}