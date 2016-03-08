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
        
        let id = String(userJson["uid"].int!)
        let firstName = userJson["first_name"].string!
        let lastName = userJson["last_name"].string!
        let photoUrlString = userJson["photo_max"].string!
        
        return User(
            id: id,
            firstName: firstName,
            lastName: lastName,
            photoUrlString: photoUrlString
        )
    }
}
