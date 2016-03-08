//
//  Error.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 06/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

struct Error {
    var code: Int = -1
    var message: String = "Неизвестная ошибка сервера"
    
    init() {}
    
    init(code: Int, message: String) {
        self.code = code
        self.message = message
    }
    
}

func print(error: Error) {
    print("========ERROR========")
    print("Code: \(error.code)")
    print("Message: \(error.message)")
    print("======END ERROR======")
}