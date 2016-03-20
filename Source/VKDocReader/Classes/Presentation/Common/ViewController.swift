//
//  ViewController.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 05/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    lazy var isRootViewController: Bool = {
        return self.navigationController?.viewControllers[0] == self
    }()
}

extension UIViewController {
    var serviceLayer: ServiceLayer {
            return ServiceLayer.sharedServiceLayer
    }
}