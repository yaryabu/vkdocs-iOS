//
//  Document.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 05/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import RealmSwift

class Document: Object {
    dynamic var id: String!
    dynamic var ownerId: String!
    dynamic var title: String!
    dynamic var size: String!
    dynamic var ext: String!
    dynamic var urlString: String!
    dynamic var date: String!
    
    dynamic var thumbnailUrlString: String?
    dynamic var smallThumbnailUrlString: String?
    dynamic var accessKey: String?

    dynamic var fileDirectory: String {
        get {
            let dir = Const.Directories.vaultDir + "/" + id
            if Bash.fileExists(dir, isDirectory: true) == false {
                Bash.mkdir(dir)
            }
            return dir
        }
    }
    dynamic var filePath: String?
    dynamic var fileName: String?
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

//приходится сравнивать все элементы, а не только id т.к. у объекта
//могут измениться любые поля, а id останется прежним
func ==(left: Document, right: Document) -> Bool {
    let result =
        left.id == right.id &&
        left.ownerId == right.ownerId &&
        left.title == right.title &&
        left.size == right.size &&
        left.ext == right.ext &&
        left.urlString == right.urlString &&
        left.date == right.date &&
        left.thumbnailUrlString == right.thumbnailUrlString &&
        left.smallThumbnailUrlString == right.smallThumbnailUrlString

    return result
}

func !=(left: Document, right: Document) -> Bool {
    return !(left == right)
}

//сравниваем по порядку т.к. он тоже важен
func ==(left: [Document], right: [Document]) -> Bool {
    if left.count != right.count {
        return false
    }
    
    for i in 0..<left.count {
        if left[i] != right[i] {
            return false
        }
    }
    
    return true
}

func !=(left: [Document], right: [Document]) -> Bool {
    return !(left == right)
}
