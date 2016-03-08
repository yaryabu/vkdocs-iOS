//
//  AuthService.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 05/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import SSKeychain

class AuthService: Service {
    
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    
    var token: String? {
        get {
            return SSKeychain.passwordForService(Const.Keychain.serviceName, account: Const.Keychain.sharedAccountName)
        }
        set {
            if newValue != nil {
                SSKeychain.setPassword(newValue, forService: Const.Keychain.serviceName, account: Const.Keychain.sharedAccountName)
            } else {
                SSKeychain.deletePasswordForService(Const.Keychain.serviceName, account: Const.Keychain.sharedAccountName)
            }
        }
    }
    var userId: String? {
        get {
            return self.userDefaults.stringForKey(Const.UserDefaults.userIdKey)
        }
        set {
            self.userDefaults.setObject(newValue, forKey: Const.UserDefaults.userIdKey)
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
        print(self.token, self.userId)
    }
}
