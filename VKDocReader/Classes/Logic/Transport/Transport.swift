//
//  Transport.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 05/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import Alamofire
import SwiftyJSON

/**
 Транспортный уровень МП. Предназначен для загрузки небольних данных. Для загрузки больших файлов нужно использовать LoadTaskManager.
 */
class Transport: Alamofire.Manager {
    static let sharedTransport = Transport()

    private init() {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 10
        config.HTTPShouldSetCookies = false
        
        config.HTTPAdditionalHeaders = Manager.defaultHTTPHeaders
        
        super.init(configuration: config)
    }
    
    func getJSON(urlString: String, parameters: [String:AnyObject]?, completion: (json: JSON) -> Void, failure: (error: NSError) -> Void) {
        //TODO: вынести добалвение параметра на уровень сервисов
        var newParams = parameters ?? [:]
        newParams["v"] = Const.Network.apiVersion

        self.request(.GET, urlString, parameters: newParams, encoding: .URL, headers: nil)
            .responseJSON { (response) -> Void in
                debugLog(response)
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    Dispatch.defaultQueue({ () -> () in
                        let json = JSON(value)
                        completion(json: json)
                    })
                }
            case .Failure(let error):
                failure(error: error)
            }
        }
    }
    
    func getData(urlString: String, completion: (data: NSData) -> Void, failure: (error: NSError) -> Void) {
        self.request(.GET, urlString, parameters: nil, encoding: .URL, headers: nil)
            .responseData { (response) -> Void in
                debugLog(response)
            switch response.result {
            case .Success:
                Dispatch.defaultQueue({ () -> () in
                    completion(data: response.data!)
                })
            case .Failure(let error):
                failure(error: error)
            }
        }
    }

}