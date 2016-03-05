//
//  AuthViewController.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 05/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit

class AuthViewController: ViewController {

    @IBAction func logInButtonPressed(sender: AnyObject) {
        self.performSegueWithIdentifier(Const.StoryboardSegues.logInButtonPressed, sender: self)
    }
}
