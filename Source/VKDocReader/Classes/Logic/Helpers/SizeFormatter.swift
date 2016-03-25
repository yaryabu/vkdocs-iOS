//
//  SizeFormatter.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 22/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import Foundation
//1000, потому что apple и ВК
class SizeFormatter {
    class func closestFormatFromBytes(bytes: Int) -> (number: Int, unitTypeName: String) {
        let doubleBytes = Double(bytes)
        if doubleBytes < 1000 {
            return (Int(doubleBytes), "Байт")
        }
        let roundedKb = Int(round(doubleBytes/1000.0))
        if roundedKb < 1000 {
            return (roundedKb, "КБ")
        }
        let roundedMb = Int(round(doubleBytes/1000.0/1000.0))
        if roundedMb < 1000 {
            return (roundedMb, "МБ")
        }
        let roundedGb = Int(round(doubleBytes/1000.0/1000.0/1000.0))
        if roundedGb < 1000 {
            return (roundedGb, "ГБ")
        }
        return (0, "")
    }
    class func kbytesFromBytes(bytes: Int) -> Double {
        return Double(bytes)/1000.0
    }
}