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
        self.transport.getJSON(Const.Network.baseUrl + "/users.get", parameters: ["access_token":self.authService.token!, "fields" : "photo_max"], completion: { (json) -> Void in
            self.checkError(json)
            let user = UserParser.parseUser(json)
            Dispatch.mainQueue({ () -> () in
                completion(user: user)
            })
            }) { (error) -> Void in
                failure(error: self.createError(error))
        }
    }
    
    func getUserAvatarData(user: User, completion: (data: NSData) -> Void, failure: (error: Error) -> Void) {
        self.transport.getData(user.photoUrlString, completion: { (data) -> Void in
            Dispatch.mainQueue({ () -> () in
                completion(data: data)
            })
            }) { (error) -> Void in
                failure(error: self.createError(error))
        }
    }
    
}