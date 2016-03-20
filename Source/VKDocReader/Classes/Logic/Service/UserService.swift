//
//  UserService.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 06/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import Foundation

class UserService: Service {
    
    let authService: AuthService
    let userSettingsSerivce: UserSettingsSerivce
    
    init(authService: AuthService, userSettingsSerivce: UserSettingsSerivce) {
        self.authService = authService
        self.userSettingsSerivce = userSettingsSerivce
    }
    
    func getUserInfo(completion: (user: User) -> Void, failure: (error: Error) -> Void) {
        self.transport.getJSON(Const.Network.baseUrl + "/users.get", parameters: ["access_token":self.authService.token!, "fields" : "photo_50"], completion: { (json) -> Void in
            if let error = self.checkError(json) {
                Dispatch.mainQueue({ () -> () in
                    failure(error: error)
                })
                return
            }
            let user = UserParser.parseUser(json)
            Dispatch.mainQueue({ () -> () in
                completion(user: user)
            })
            }) { (error) -> Void in
                if let error = self.createError(error) {
                    failure(error: error)
                }
        }
    }
    
    func getUserAvatarData(user: User, completion: (data: NSData) -> Void, failure: (error: Error) -> Void) {
        self.transport.getData(user.photoUrlString, completion: { (data) -> Void in
            Dispatch.mainQueue({ () -> () in
                completion(data: data)
            })
            }) { (error) -> Void in
                if let error = self.createError(error) {
                    failure(error: error)
                }
        }
    }
    
}