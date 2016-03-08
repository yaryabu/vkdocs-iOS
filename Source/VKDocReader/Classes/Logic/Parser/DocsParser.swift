//
//  DocsParser.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 05/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import SwiftyJSON

class DocsParser: Parser {
    class func parseDocument(json: JSON) -> Document {
        let document = Document()
        document.id = String(json["did"].int!)
        document.ownerId = String(json["owner_id"].int!)
        document.title = json["title"].string!
        document.size = String(json["size"].int!)
        document.ext = json["ext"].string!
        document.urlString = json["url"].string!
        document.date = String(json["date"].int!)
        document.thumbnailUrlString = json["thumb"].string
        document.smallThumbnailUrlString = json["thumb_s"].string
        
        return document
    }
    
    class func parseDocuments(json: JSON) -> [Document] {
        
        var documentsArray: [Document] = []
        
        for (index,subJson):(String, JSON) in json["response"] {
            // пропускаем счетчик элементов
            if index == "0" && subJson.int != nil {
                ServiceLayer.sharedServiceLayer.userSettingsService.currentDocumentsCount = subJson.int!
                continue
            }
            documentsArray.append(self.parseDocument(subJson))
        }
        
        return documentsArray
    }
}
