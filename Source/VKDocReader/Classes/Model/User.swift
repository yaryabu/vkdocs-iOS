//
//  User.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 06/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

class User {
    let id: String
    let firstName: String
    let lastName: String
    let photoUrlString: String
    
    init(id: String, firstName: String, lastName: String, photoUrlString: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.photoUrlString = photoUrlString
    }
}