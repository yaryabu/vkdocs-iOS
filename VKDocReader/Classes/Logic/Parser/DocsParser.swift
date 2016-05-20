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
        document.id = String(json["id"].int!)
        document.ownerId = String(json["owner_id"].int!)
        document.title = json["title"].string!
        document.size = String(json["size"].int!)
        document.ext = json["ext"].string!
        document.urlString = json["url"].string!
        document.date = String(json["date"].int!)
        
        for (_, subJson):(String, JSON) in json["preview"]["photo"]["sizes"] {
            if subJson["type"].string == "m" {
                document.thumbnailUrlString = subJson["src"].string
            }
        }
        
        
        return document
    }
    
    class func parseDocuments(json: JSON) -> (documentsArray: [Document], count: Int) {
        
        var documentsArray: [Document] = []
        let count = json["response"]["count"].int!
        for (index ,subJson):(String, JSON) in json["response"]["items"] {
            let newDoc = self.parseDocument(subJson)
            newDoc.order = Int(index)!
            documentsArray.append(newDoc)
        }
        
        return (documentsArray, count)
    }
}
