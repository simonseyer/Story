//
//  Day.swift
//  Story
//
//  Created by COBI on 20.04.16.
//
//

import Foundation

public struct Day {
    
    let date: NSDate
    let image: Image
    let text: String

}

public struct Image {
    
    let name: String
    let latitude: Float64
    let longitude: Float64
    
}

public struct Trip {
    
    let identifier: String
    let name: String
    let days: [Day]

}

extension Day : Equatable {}

public func ==(lhs: Day, rhs: Day) -> Bool {
    return
        lhs.date == rhs.date &&
        lhs.image == rhs.image &&
        lhs.text == rhs.text
}

extension Image : Equatable {}

public func ==(lhs: Image, rhs: Image) -> Bool {
    return
            lhs.name == rhs.name &&
            lhs.latitude == rhs.latitude &&
            lhs.longitude == rhs.longitude
}

extension Trip: Equatable {}

public func ==(lhs: Trip, rhs: Trip) -> Bool {
    return lhs.identifier == rhs.identifier
}