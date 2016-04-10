//
//  ImageService.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 06/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit
import SwiftyJSON

class ImageService: Service {
    func getImage(urlString: String, completion: (imageData: NSData) -> Void, failure: (error: Error) -> Void) {
        self.transport.getData(urlString, completion: { (data) -> Void in
            if let error = self.checkError(JSON(data: data)) {
                Dispatch.mainQueue({ () -> () in
                    failure(error: error)
                })
                return
            }
            Dispatch.mainQueue({ () -> () in
                completion(imageData: data)
            })
            }, failure: { (error) -> Void in
                if let error = self.createError(error) {
                    failure(error: error)
                }
        })
    }
    
}
