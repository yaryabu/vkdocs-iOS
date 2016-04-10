//
//  Service.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 05/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import SwiftyJSON
import RealmSwift

/**
 Базовый сервис, от которого наследуются остальные сервисы
 */
class Service {
    let transport = Transport.sharedTransport
    let loadTaskManager = LoadTaskManager.sharedManager
    
    /**
     Проверка выдачи на специализированные ошибки ВК
    */
    func checkError(json: JSON) -> Error? {
        let errorJson = json["error"]
        if errorJson != nil {
            
            Analytics.logVKApiError(
                errorJson["error_code"].int ?? -1,
                message: errorJson["error_msg"].string ?? "No msg"
            )
            
            print("====VK_ERROR====")
            print("====Code: \(errorJson["error_code"].int)====")
            print("====Message: \(errorJson["error_msg"].string)====")
            print("====Params: \(errorJson["request_params"]) ====")
            print("====END====")
            
            switch errorJson["error_code"] {
            case 1:
                return Error()
            case 2:
                // приложение выключено
                return Error()
            case 3:
                // неизвестный метод
                return Error()
            case 4:
                // неверная подпись
                return Error()
            case 5:
                return Error(code: 5, message: "BAD_AUTH".localized)
            case 7:
                return Error(code: 7, message: "BAD_ACCESS".localized)
            case 10:
                // внутренняя ошибка сервера
                return Error(code: 10, message: "UNKNOWN_VK_SERVER_ERROR".localized)
            case 14:
                var newError =  Error(code: 14, message: "NEED_CAPTCHA".localized)
                newError.captchaId = errorJson["captcha_sid"].string!
                newError.captchaUrlString = errorJson["captcha_img"].string!
                newError.requestParams = errorJson["request_params"]
                return newError
            case 23:
                // метод выключен
                return Error()
            case 100:
                // неверный параметр
                return Error()
            case 101:
                // неверный API ID
                return Error()
            case 113:
                // неверный user ID
                return Error(code: 113, message: "WRONG_USER_ID".localized)
            default:
                return Error()
            }
        }
        return nil
    }
    
    /// Перевод из NSError от транспорта в кастомную ошибку
    func createError(error: NSError) -> Error? {
        //FIXME: сделать обработку too many http redirects
        print("====NS_ERROR====")
        print("====Code: \(error.code))====")
        print("====Message: \(error.localizedDescription)====")
        print("====Error: \(error))====")
        print("====END====")
        
        Analytics.logError(error)
        
        switch error.code {
        case -999:
            // Загрузка отменена пользователем
            return nil
        default:
            let newError = Error(code: error.code, message: error.localizedDescription)
            return newError
        }
    }
    
    func retryRequest(error: Error, captchaText: String) {
        
    }
    
    /// Абстрактный метод для переопределения наследниками. Удаляет всю инфомрацию о сервисе. К примеру, для выхода их приложения
    func deleteAllInfo() {}
}