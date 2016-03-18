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
}

//extension UITableViewDataSource {
//    func refresh(refreshEnded: () -> Void, refreshFailed: (error: Error) -> Void) {}
//}