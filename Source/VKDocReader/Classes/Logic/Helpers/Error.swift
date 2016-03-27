//
//  Error.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 06/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

/**
 Кастомная ошибка приложения. Все сторонние ошибки должны трансформироваться в тип Error.
 */
struct Error {
    var code: Int = -1
    var message: String = "Неизвестная ошибка сервера"
    var captchaId: String?
    var captcha_img: String?
    
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