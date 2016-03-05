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
            return SSKeychain.passwordForService("serviceName", account: "account")
        }
        set {
            if newValue != nil {
                SSKeychain.setPassword(newValue, forService: "serviceName", account: "account")
            } else {
                SSKeychain.deletePasswordForService("serviceName", account: "account")
            }
        }
    }
    var userId: String? //{
//        get {
//            return "fff"
//        }
//        set {
//            
//        }
//    }
    
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
