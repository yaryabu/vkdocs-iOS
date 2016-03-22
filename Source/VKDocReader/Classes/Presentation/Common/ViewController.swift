//
//  ViewController.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 05/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit
import CRToast

class ViewController: UIViewController {
    lazy var isRootViewController: Bool = {
        return self.navigationController?.viewControllers[0] == self
    }()
    
}

extension UIViewController {
    var serviceLayer: ServiceLayer {
        return ServiceLayer.sharedServiceLayer
    }
    
    
    
    func handleError(error: Error) {
        print(error)
        switch error.code {
        case 5:
            //TODO:
            print("auth error")
            ToastManager.sharedInstance.presentError(error)
        case 14:
            //TODO:
            print("captcha")
            ToastManager.sharedInstance.presentError(error)
        case -999:
            print("loadError")
        default:
            ToastManager.sharedInstance.presentError(error)
        }
    }
}