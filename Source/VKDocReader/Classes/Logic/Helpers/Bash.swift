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
            try NSFileManager.defaultManager().copyItemAtPath(from, toPath: to)
            return true
        } catch {
            return false
        }
    }
    
    class func mv(from: String, to: String) -> Bool {
        do {
            try NSFileManager.defaultManager().moveItemAtPath(from, toPath: to)
            return true
        } catch {
            return false
        }
    }
    
    class func rm(filePath: String) -> Bool {
        do {
            try NSFileManager.defaultManager().removeItemAtPath(filePath)
            return true
        } catch {
            return false
        }
    }
    
    class func du(path: String) -> UInt {
        var totalSize: UInt = 0
        
        for file in ls(path) {
            let filePath = path + "/" + file
            if isDirectory(filePath) {
                totalSize += du(filePath)
            } else {
                totalSize += try! NSFileManager.defaultManager().attributesOfItemAtPath(filePath)[NSFileSize] as! UInt
            }
        }
        
        return totalSize
    }
    
    class func du(path: String, completion: (UInt) -> Void) {
        Dispatch.mainQueue() { () -> () in
            completion(du(path))
        }
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