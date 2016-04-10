//
//  Dispatch.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 06/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import Foundation

/**
 Обертка libdispatch в синтаксис Swift
 */
class Dispatch {
    
    static let defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    
    static func mainQueue(closure: () -> ()) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            closure()
        }
    }
    static func defaultQueue(closure: () -> ()) {
        dispatch_async(defaultQueue) { () -> Void in
            closure()
        }
    }
    static func mainQueueAfter(delay: Double, closure: () -> ()) {
        dispatch_after(delayTime(delay), dispatch_get_main_queue()) {
            closure()
        }
    }
    
    static func defaultQueueAfter(delay: Double, closure: () -> ()) {
        dispatch_after(delayTime(delay), defaultQueue) {
            closure()
        }
    }
    
    private static func delayTime(delay: Double) -> dispatch_time_t {
        return dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
    }
}