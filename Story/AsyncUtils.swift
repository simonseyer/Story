//
//  AsyncUtils.swift
//  Story
//
//  Created by COBI on 27.04.16.
//
//

import Foundation

class Background {
    
    static func execute<T>(_ block: (Void) -> T, completionBlock: (T) -> Void) {
        DispatchQueue.global(attributes: DispatchQueue.GlobalAttributes.qosUserInitiated).async {
            let result = block()
            DispatchQueue.main.async {
                completionBlock(result)
            }
        }
    }
    
    static func delay(_ delay:Double, closure:()->()) {
        DispatchQueue.main.after(
            when: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
}
