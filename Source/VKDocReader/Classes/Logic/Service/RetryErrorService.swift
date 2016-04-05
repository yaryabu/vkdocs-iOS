//
//  RetryErrorService.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 03/04/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import Foundation
import SwiftyJSON

class RetryErrorService: Service {
    let authService: AuthService
    let userSettingsSerivce: UserSettingsSerivce
    
    init(authService: AuthService, userSettingsSerivce: UserSettingsSerivce) {
        self.authService = authService
        self.userSettingsSerivce = userSettingsSerivce
    }
    
    func submitCaptcha(error: Error, captchaText: String, completion: () -> Void, failure: (error: Error) -> Void) {
        let requestInfo = retryRequestParameters(error, captchaText: captchaText)
        transport.getJSON(Const.Network.baseUrl + requestInfo.method, parameters: requestInfo.queryParams, completion: { (json) in
            if let error = self.checkError(json) {
                Dispatch.mainQueue({ () -> () in
                    failure(error: error)
                })
                return
            }
            Dispatch.mainQueue({ () -> () in
                completion()
            })
            }) { (error) in
                if let error = self.createError(error) {
                    failure(error: error)
                }
        }
    }
    
    
    
    func retryRequestParameters(error: Error, captchaText: String) -> (method: String, queryParams: [String:String]) {
        
        var method: String!
        var params: [String:String] = [:]
        
        for (_,subJson):(String, JSON) in error.requestParams! {
            if subJson["key"].string! == "oauth" {
                continue
            } else if subJson["key"].string! == "method" {
                method = "/" + subJson["value"].string!
            } else {
                params[subJson["key"].string!] = subJson["value"].string!
            }
        }
        params["captcha_key"] = captchaText
        params["captcha_sid"] = error.captchaId
        
        params["access_token"] = authService.token
        
        return (method: method, queryParams: params)
    }
}