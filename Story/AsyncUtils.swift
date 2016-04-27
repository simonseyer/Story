//
//  AsyncUtils.swift
//  Story
//
//  Created by COBI on 27.04.16.
//
//

import Foundation

class Background {
    
    static func execute<T>(block: Void -> T, completionBlock: T -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            let result = block()
            dispatch_async(dispatch_get_main_queue()) {
                completionBlock(result)
            }
        }
    }
}
