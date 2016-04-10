//
//  AuthService.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 05/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import SSKeychain

class AuthService: Service {

    var token: String? {
        get {
            let defaults = NSUserDefaults(suiteName: Const.UserDefaults.appGroupId)
            return defaults?.stringForKey(Const.UserDefaults.userToken)
        }
        set {
            let defaults = NSUserDefaults(suiteName: Const.UserDefaults.appGroupId)
            defaults?.setObject(newValue, forKey: Const.UserDefaults.userToken)
        }
    }

    var userId: String? {
        get {
            let defaults = NSUserDefaults(suiteName: Const.UserDefaults.appGroupId)
            return defaults?.stringForKey(Const.UserDefaults.userIdKey)
        }
        set {
            let defaults = NSUserDefaults(suiteName: Const.UserDefaults.appGroupId)
            defaults?.setObject(newValue, forKey: Const.UserDefaults.userIdKey)
        }
    }
    
    func saveAuthData(paramsString: String) {
        let params = paramsString.componentsSeparatedByString("&")

        for param in params {
            if param.containsString("access_token") {
                self.token = param.componentsSeparatedByString("=")[1]
            } else if param.containsString("user_id") {
                self.userId = param.componentsSeparatedByString("=")[1]
            }
        }
    }
    
    override func deleteAllInfo() {
        self.token = nil
        self.userId = nil
    }
}
