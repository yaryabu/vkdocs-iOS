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
    
    class func ls() -> [String] {
        do {
            let ls = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(".")
            return ls
        } catch {
            return []
        }
    }
    
    class func ls(dir: String) -> [String] {
        do {
            let ls = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(dir)
            return ls
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
    
    class func fileExists(dirPath: String, isDirectory: Bool) -> Bool {
        var objcBool = ObjCBool(isDirectory)
        return NSFileManager.defaultManager().fileExistsAtPath(dirPath, isDirectory: &objcBool)
    }
}