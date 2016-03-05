//
//  Const.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 05/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

struct Const {
    struct Common {
        static let clientId = "5295261"
    }
    
    struct Network {
        static let baseUrl = "https://api.vk.com/method"
        
        struct VKScopes {
            static let docsScope = "docs"
        }
        
//        struct Auth {
//            static let baseUrl = "https://oauth.vk.com/authorize"
//            static let redirectURI = "https://oauth.vk.com/blank.html"
        static let authUrlString = "https://oauth.vk.com/authorize?client_id=\(Const.Common.clientId)&display=mobile&redirect_uri=https://oauth.vk.com/blank.html&scope=\(Const.Network.VKScopes.docsScope)&response_type=token"
//        }
    }
    
    struct StoryboardIDs {
        static let AuthViewController = "AuthViewController"
        static let loggedInRoot = "loggedInRoot"
    }
    
    struct StoryboardSegues {
        static let logInButtonPressed = "logInButtonPressed"
        static let logInSuccess = "logInSuccess"
    }
}

