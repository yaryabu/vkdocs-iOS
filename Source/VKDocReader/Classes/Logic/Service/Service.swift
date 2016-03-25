//
//  Service.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 05/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import SwiftyJSON
import RealmSwift

class Service {
    let transport = Transport.sharedTransport
    let loadTaskManager = LoadTaskManager.sharedManager
    
    //TODO: доработать специальные ошибки
    func checkError(json: JSON) -> Error? {
        let errorJson = json["error"]
        if errorJson != nil {
            print(errorJson)
            switch errorJson["error_code"] {
            case 1:
                return Error(code: 1, message: "Неизвестная ошибка")
            case 2:
//                print("Ошибка 2 (приложение выключено)")
                return Error(code: 1, message: "Неизвестная ошибка")
            case 3:
//                print("Ошибка 3 (неизвестный метод)")
                return Error(code: 1, message: "Неизвестная ошибка")
            case 4:
//                print("Ошибка 4 (неверная подпись)")
                return Error(code: 1, message: "Неизвестная ошибка")
            case 5:
//                print("Ошибка 5 (авторизация не удалась)")
                return Error(code: 5, message: "Авторизация не удалась")
            case 7:
//                print("Ошибка 7 (нет прав)")
                return Error(code: 7, message: "Ошибка доступа")
            case 10:
//                print("Ошибка 10 (внутренняя ошибка сервера)")
                return Error(code: 1, message: "Неизвестная ошибка")
            case 14:
//                print("Ошибка 14 (нужна капча)")
//                let error = Error(code: 14, message: "Необходимо ввести код с картинки")
//                error.captchaId = json[]
                return Error(code: 14, message: "Необходимо ввести код с картинки")
            case 23:
//                print("Ошибка 23 (метод выключен)")
                return Error(code: 1, message: "Неизвестная ошибка")
            case 100:
//                print("Ошибка 100 (неверный параметр)")
                return Error(code: 1, message: "Неизвестная ошибка")
            case 101:
//                print("Ошибка 101 (неверный API ID)")
                return Error(code: 1, message: "Неизвестная ошибка")
            case 113:
//                print("Ошибка 113 (неверный user ID)")
                return Error(code: 113, message: "Ошибка авторизации. Попробуйте перезапустить приложение")
            default:
                return Error(code: 1, message: "Неизвестная ошибка")
            }
        }
        return nil
    }
    func createError(error: NSError) -> Error? {
        print("Error", error.code, error.localizedDescription)
        switch error.code {
        case -999:
            return nil
//            return Error(code: -999, message: "Загрузка отменена пользователем")
        default:
            return Error(code: error.code, message: error.localizedDescription)
        }
    }
    
    func deleteAllInfo() {
        
    }
}