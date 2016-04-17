//
//  DateFormatter.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 06/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import Foundation

/**
 Обертка NSDateFormater для удобства
 */
class DateFormatter {
    
    class func stringFromTimestamp(timestamp: Int, formatString: String) -> String {
        
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "ru_RU")
        formatter.dateFormat = formatString
        
        let date = NSDate(timeIntervalSince1970: Double(timestamp))
        
        return formatter.stringFromDate(date)
    }
    
}