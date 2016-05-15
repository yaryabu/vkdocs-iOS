//
//  Localize.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 11/04/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: "")
    }
    func localizedStringsDict(numberToFormat: Int) -> String {
        return String.localizedStringWithFormat(self.localized, numberToFormat)
    }
}