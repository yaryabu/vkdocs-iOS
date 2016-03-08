//
//  ServiceLayer.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 05/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

class ServiceLayer {
    static let sharedServiceLayer = ServiceLayer()
    
    let authService: AuthService
    let userSettingsService: UserSettingsSerivce
    let userService: UserService
    let docsService: DocsService
    let imageService: ImageService
    
    init() {
        self.authService = AuthService()
        self.userSettingsService = UserSettingsSerivce()
        self.userService = UserService(authService: self.authService, userSettingsSerivce: self.userSettingsService)
        self.docsService = DocsService(authService: self.authService, userSettingsSerivce: self.userSettingsService)
        self.imageService = ImageService()
    }
}