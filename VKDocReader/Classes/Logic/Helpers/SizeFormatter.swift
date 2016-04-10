//
//  SizeFormatter.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 22/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import Foundation
//1000, а не 1024, потому что apple и ВК оба используют 1000

/**
 Форматирование размера файла
*/
class SizeFormatter {
    
    /**
     Форматирование файлов, наиоблее подходящее для чтения человером
     - returns: кортеж из размера и названия для размера (e.g. "КБ", "МБ")
    */
    class func closestFormatFromBytes(bytes: Int) -> (number: Int, unitTypeName: String) {
        let doubleBytes = Double(bytes)
        if doubleBytes < 1000 {
            return (Int(doubleBytes), "BYTE".localized)
        }
        let roundedKb = Int(round(doubleBytes/1000.0))
        if roundedKb < 1000 {
            return (roundedKb, "KB".localized)
        }
        let roundedMb = Int(round(doubleBytes/1000.0/1000.0))
        if roundedMb < 1000 {
            return (roundedMb, "MB".localized)
        }
        let roundedGb = Int(round(doubleBytes/1000.0/1000.0/1000.0))
        if roundedGb < 1000 {
            return (roundedGb, "GB".localized)
        }
        return (0, "")
    }
    
    class func kbytesFromBytes(bytes: Int) -> Double {
        return Double(bytes)/1000.0
    }
}