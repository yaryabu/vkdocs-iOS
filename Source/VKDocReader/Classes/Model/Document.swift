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
    dynamic var thumbnailData: NSData?
    
    dynamic var accessKey: String?

    dynamic var vkHash: String! {
        get {
            let queryParams = urlString
                .componentsSeparatedByString("?")[1]
                .componentsSeparatedByString("&")
            return queryParams.filter({ $0.containsString("hash")})[0]
                .componentsSeparatedByString("=")[1]
        }
    }
    
    dynamic var fileDirectory: String {
        get {
            let dir = Const.Directories.vaultDir + "/" + id
            if Bash.fileExists(dir) == false {
                Bash.mkdir(dir)
            }
            return dir
        }
    }
    dynamic var fileName: String? {
        get {
            let fileDirContents = Bash.ls(fileDirectory)
            if fileDirContents.count > 0 {
                return fileDirContents[0]
            } else {
                return nil
            }
        }
    }
    
    dynamic var filePath: String? {
        get {
            if fileName != nil  {
                return fileDirectory + "/" + fileName!
            } else {
                return nil
            }
        }
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

//приходится сравнивать все элементы, а не только id т.к. у объекта
//могут измениться любые поля, а id останется прежним
func ==(left: Document, right: Document) -> Bool {
    let result = true &&
        left.id == right.id &&
        left.ownerId == right.ownerId &&
        left.title == right.title &&
        left.size == right.size &&
        left.ext == right.ext &&
        left.vkHash == right.vkHash &&
        left.date == right.date &&
        left.thumbnailUrlString == right.thumbnailUrlString 
    //urlString не сравнивается т.к. меняется, даже если файл остается прежним

    if result == false {
        print("====DOCS UNEQUAL====")
        print(left)
        print("====SECOND====")
        print(right)
        print("====END====")
    }
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

func print(document: Document) {
    print("id", document.id)
    print("ownerId", document.ownerId)
    print("title", document.title)
    print("size", document.size)
    print("urlString", document.urlString)
    print("ext", document.ext)
    print("vkHash", document.vkHash)
    print("date", document.date)
    print("thumbnailUrlString", document.thumbnailUrlString)
}
