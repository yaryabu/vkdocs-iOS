//
//  DateFormatter.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 06/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import Foundation

class DateFormatter: NSDateFormatter {
    override init() {
        super.init()
        self.locale = NSLocale(localeIdentifier: "ru_RU")
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func stringFromTimestamp(timestamp: Int, formatString: String) -> String {
        let date = NSDate(timeIntervalSince1970: Double(timestamp))
        self.dateFormat = formatString
        return self.stringFromDate(date)
    }
}