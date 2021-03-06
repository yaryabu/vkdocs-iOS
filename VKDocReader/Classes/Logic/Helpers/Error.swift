//
//  Error.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 06/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import SwiftyJSON

/**
 Кастомная ошибка приложения. Все сторонние ошибки должны трансформироваться в тип Error.
 */
struct Error {
    var code: Int = 0
    var message: String = "UNKNOWN_ERROR".localized
    var captchaId: String?
    var captchaUrlString: String?
    var requestParams: JSON?
    
    init() { debugLog(self) }
    
    init(code: Int, message: String) {
        self.code = code
        self.message = message
        debugLog(self)
    }
    
}

func print(error: Error) {
    print("========ERROR========")
    print("Code: \(error.code)")
    print("Message: \(error.message)")
    print("======END ERROR======")
}