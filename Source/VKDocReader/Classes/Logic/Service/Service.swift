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
    
    //WARNING: обработка ошибок
    func checkError(json: JSON) -> Error? {
        let errorJson = json["error"]
        if errorJson != nil {
            print(errorJson)
            switch errorJson["error_code"] {
            case 1:
                print("Ошибка 1 (неизвестная ошибка)")
            case 2:
                print("Ошибка 2 (приложение выключено)")
            case 3:
                print("Ошибка 3 (неизвестный метод)")
            case 4:
                print("Ошибка 4 (неверная подпись)")
            case 5:
                print("Ошибка 5 (авторизация не удалась)")
            case 7:
                print("Ошибка 7 (нет прав)")
            case 10:
                print("Ошибка 10 (внутренняя ошибка сервера)")
            case 23:
                print("Ошибка 23 (метод выключен)")
            case 100:
                print("Ошибка 100 (неверный параметр)")
            case 101:
                print("Ошибка 101 (неверный API ID)")
            case 113:
                print("Ошибка 113 (неверный user ID)")
            default:
                print("Ошибка default")
            }
            print("Ошибка \(json.rawValue)")
        }
        return nil
    }
    func createError(error: NSError) -> Error {
        print("Error", error.code, error.localizedDescription)
        switch error.code {
        case -999:
            return Error(code: -999, message: "Загрузка отменена пользователем")
        default:
            return Error(code: error.code, message: error.localizedDescription)
        }
    }
}