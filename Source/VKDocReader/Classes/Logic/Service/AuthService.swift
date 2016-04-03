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
//            return SSKeychain.passwordForService(Const.Keychain.serviceName, account: Const.Keychain.sharedAccountName)
        }
        set {
            let defaults = NSUserDefaults(suiteName: Const.UserDefaults.appGroupId)
            defaults?.setObject(newValue, forKey: Const.UserDefaults.userToken)
            
            
//            let query = SSKeychainQuery()
//            query.account = Const.Keychain.sharedAccountName
//            query.service = Const.Keychain.serviceName
//            query.accessGroup = "SH46XG936M.ru.yaryabu.VKDocs"
//            if newValue != nil {
//                query.password = newValue
//                do {
//                    try query.save()
//                } catch {
//                    print("saveError")
//                }
//            } else {
//                do {
//                    try query.deleteItem()
//                } catch {
//                    print("deleteError")
//                }
//            }
            
//            if newValue != nil {
//                SSKeychain.setPassword(newValue, forService: Const.Keychain.serviceName, account: Const.Keychain.sharedAccountName)
//            } else {
//                SSKeychain.deletePasswordForService(Const.Keychain.serviceName, account: Const.Keychain.sharedAccountName)
//            }
        }
    }

    var userId: String? {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey(Const.UserDefaults.userIdKey)
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: Const.UserDefaults.userIdKey)
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
