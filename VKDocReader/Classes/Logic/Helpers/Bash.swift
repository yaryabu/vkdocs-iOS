//
//  Bash.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 08/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import Foundation

//TODO: нужна обработка ошибок в catch

/**
 Обертка NSFileManager в родной синтаксис командной строки
 */
class Bash {
    /**
     Сменить текущую директорию
    */
    class func cd(dir: String) {
        NSFileManager.defaultManager().changeCurrentDirectoryPath(dir)
    }
    
    /**
     Вывести текущую директорию
     - returns: текущая директория в формате строки
    */
    class func pwd() -> String {
        return NSFileManager.defaultManager().currentDirectoryPath
    }
    
    /**
     Вывести список элементов в директории
     - parameter dir: директория
     - returns: массив названий элементов директории
    */
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
    /**
     Создать директорию
     - parameter dir: директория, которую нужно создать
    */
    class func mkdir(dir: String) {
        do {
            try NSFileManager.defaultManager().createDirectoryAtPath(dir, withIntermediateDirectories: true, attributes: nil)
        } catch {
        }
    }
    
    /**
     Создать пустой файл
     -parameter filePath: путь к файлу, который нужно создать
    */
    class func touch(filePath: String)  {
        NSFileManager.defaultManager().createFileAtPath(filePath, contents: nil, attributes: nil)
    }
    
    /**
     Скопировать файл
    */
    class func cp(from: String, to: String) {
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
        } catch {
        }
    }
    
    /**
     Переместить файл
    */
    class func mv(from: String, to: String) {
        cp(from, to: to)
        if from != to {
            rm(from)
        }
    }
    
    /**
     Удалить файл
    */
    class func rm(filePath: String) {
        do {
            try NSFileManager.defaultManager().removeItemAtPath(filePath)
        } catch {
        }
    }
    
    /**
    Рекурсивное удаление файла/папки
    - parameter fromDir: директория, из которой нужно удалить все упоминания файла
    - parameter fileName: имя файла, который нужно удалить
    */
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
    
    /**
     Размер файла/папки и всех её детей
    */
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