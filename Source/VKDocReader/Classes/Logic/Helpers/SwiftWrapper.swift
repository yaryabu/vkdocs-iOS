//
//  SwiftWrapper.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 02/04/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import Foundation


/// Generic обертка для swift структур, которые плохо взаимодействуют с objc
/// К примеру, структуры нельзя передавать в NSNotificationCenter
class Wrapper<T> {
    var wrappedValue: T
    init(theValue: T) {
        wrappedValue = theValue
    }
}