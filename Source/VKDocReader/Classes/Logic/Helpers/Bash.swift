//
//  Bash.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 08/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import Foundation

class Bash {
    class func cd(dir: String) -> Bool {
        return NSFileManager.defaultManager().changeCurrentDirectoryPath(dir)
    }
    
    class func pwd() -> String {
        return NSFileManager.defaultManager().currentDirectoryPath
    }
    
    class func ls(dir: String) -> [String] {
        do {
            let ls = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(dir)
            return ls.filter({ (folder) -> Bool in
                if folder == ".DS_Store" {
                    return false
                } else {
                    return true
                }
            })
        } catch {
            return []
        }
    }
    
    class func mkdir(dir: String) -> Bool {
        do {
            try NSFileManager.defaultManager().createDirectoryAtPath(dir, withIntermediateDirectories: true, attributes: nil)
            return true
        } catch {
            return false
        }
    }
    
    class func touch(filePath: String) -> Bool  {
        return NSFileManager.defaultManager().createFileAtPath(filePath, contents: nil, attributes: nil)
    }
    
    class func cp(from: String, to: String) -> Bool {
        do {
            //если попытаться заменить существующий файл, то возвращается ошибка
            //сделано для случаев, если from и to одинаковые
            let bakDir = NSTemporaryDirectory() + "cp.bak"
            mkdir(bakDir)
            let bakPath = bakDir + "/" + from.componentsSeparatedByString("/").last!
            try NSFileManager.defaultManager().copyItemAtPath(from, toPath: bakPath)
            rm(to)
            try NSFileManager.defaultManager().copyItemAtPath(bakPath, toPath: to)
            rm(bakDir)
            return true
        } catch {
            return false
        }
    }
    
    class func mv(from: String, to: String) {
        cp(from, to: to)
        rm(from)
    }
    
    class func rm(filePath: String) -> Bool {
        do {
            try NSFileManager.defaultManager().removeItemAtPath(filePath)
            return true
        } catch {
            return false
        }
    }
    
    class func rmRecursively(fromDir: String, fileName: String) {
        for file in ls(fromDir) {
            let filePath = fromDir + "/" + file
            if isDirectory(filePath) {
                rmRecursively(filePath, fileName: fileName)
            }
            if file == fileName {
                rm(filePath)
            }
        }
    }
    
    class func du(path: String) -> Int {
        var totalSize: Int = 0
        
        for file in ls(path) {
            let filePath = path + "/" + file
            if isDirectory(filePath) {
                totalSize += du(filePath)
            } else {
                totalSize += try! NSFileManager.defaultManager().attributesOfItemAtPath(filePath)[NSFileSize] as! Int
            }
        }
        
        return totalSize
    }
    
    class func isDirectory(path: String) -> Bool {
        var isDirectory = ObjCBool(false)
        NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isDirectory)
        return Bool(isDirectory)
    }
    
    class func fileExists(dirPath: String) -> Bool {
        return NSFileManager.defaultManager().fileExistsAtPath(dirPath, isDirectory: nil)
    }
}