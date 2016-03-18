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
            self.checkError(JSON(data: data))
            Dispatch.mainQueue({ () -> () in
                completion(imageData: data)
            })
            }, failure: { (error) -> Void in
                failure(error: self.createError(error))
        })
    }
    
}
