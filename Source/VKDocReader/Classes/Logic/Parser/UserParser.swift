//
//  UserParser.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 06/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import SwiftyJSON

class UserParser: Parser {
    class func parseUser(json: JSON) -> User {
        let userJson = json["response"][0]
        
        let user = User()
        
        user.id = String(userJson["id"].int!)
        user.firstName = userJson["first_name"].string!
        user.lastName = userJson["last_name"].string!
        user.photoUrlString = userJson["photo_max"].string!
        
        return user
    }
}
