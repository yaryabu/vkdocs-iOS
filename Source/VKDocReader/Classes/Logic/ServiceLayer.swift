//
//  ServiceLayer.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 05/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

class ServiceLayer {
    static let sharedServiceLayer = ServiceLayer()
    
    let authService = AuthService()
    let userSettingsService = UserSettingsSerivce()
}