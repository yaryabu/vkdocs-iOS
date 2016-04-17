//
//  Logger.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 17/04/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import Foundation

func debugLog(items: Any..., _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
    #if DEBUG
        var resultString = ""
        
        for item in items {
            if let value = item as? CustomDebugStringConvertible {
                resultString += value.debugDescription + " "
            } else if let value = item as? CustomStringConvertible {
                resultString += value.description + " "
            } else {
                resultString += String(item) + " "
            }
        }
        
        resultString = String(resultString.characters.dropLast(0))
        
        let fileName = file.componentsSeparatedByString("/").last!.componentsSeparatedByString(".").first!
        let queue = NSThread.isMainThread() ? "UI" : "BG"
        let message = "<\(queue)> \(fileName).\(function)[\(line)]:\n\(resultString)\n"
        
        Dispatch.defaultQueue {
            let fileDirectory = Const.Directories.appDocumentsDir + "/logs"
            if !NSFileManager.defaultManager().fileExistsAtPath(fileDirectory, isDirectory: nil) {
                let _ = try? NSFileManager.defaultManager().createDirectoryAtPath(fileDirectory, withIntermediateDirectories: false, attributes: nil)
            }
            let filePath = fileDirectory + "/\(_logFileName()).txt"
            if !NSFileManager.defaultManager().fileExistsAtPath(filePath, isDirectory: nil) {
                NSFileManager.defaultManager().createFileAtPath(filePath, contents: message.dataUsingEncoding(NSUTF8StringEncoding), attributes: nil)
            }
            
            if let handle = NSFileHandle(forWritingAtPath: filePath) {
                handle.seekToEndOfFile()
                handle.writeData(message.dataUsingEncoding(NSUTF8StringEncoding)!)
                handle.closeFile()
            }
        }
        
        print(message)
    #endif
}

func _logFileName() -> String {
    
    let formatString = "dd-MM-yyyy"
    let formatter = NSDateFormatter()
    formatter.dateFormat = formatString
    
    return formatter.stringFromDate(NSDate())
}