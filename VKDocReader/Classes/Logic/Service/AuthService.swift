//
//  AuthService.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 05/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import SSKeychain
import VK_ios_sdk

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
    
    func beginAuth() {
        
        if VKSdk.accessToken() != nil {
            VKSdk.wakeUpSession(Const.Network.VKScopes.vkSdkAppScope, completeBlock: { (state, error) in
                if state == VKAuthorizationState.Authorized {
                    self.saveAuthData(VKSdk.accessToken())
                    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    delegate.beginTransitionToTabBar()
                } else {
                    VKSdk.authorize(Const.Network.VKScopes.vkSdkAppScope, withOptions: VKAuthorizationOptions.DisableSafariController)
                }
            })
        } else {
            VKSdk.authorize(Const.Network.VKScopes.vkSdkAppScope, withOptions: VKAuthorizationOptions.DisableSafariController)
        }
        
    }
    
    func saveAuthData(tokenInfo: VKAccessToken) {
        token = tokenInfo.accessToken
        userId = tokenInfo.userId
    }
    
    override func deleteAllInfo() {
        self.token = nil
        self.userId = nil
    }
}
