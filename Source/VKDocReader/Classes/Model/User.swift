//
//  User.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 06/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import RealmSwift

class User: Object {
    dynamic var id: String!
    dynamic var firstName: String!
    dynamic var lastName: String!
    dynamic var photoUrlString: String!
    dynamic var photoData: NSData?
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}

func ==(left: User, right: User) -> Bool {
    let result =
        left.id == right.id &&
        left.firstName == right.firstName &&
        left.lastName == right.lastName &&
        left.photoUrlString == right.photoUrlString
    
    return result
}

func !=(left: User, right: User) -> Bool {
    return !(left == right)
}