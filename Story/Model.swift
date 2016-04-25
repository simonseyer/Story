//
//  Day.swift
//  Story
//
//  Created by COBI on 20.04.16.
//
//

import Foundation

public struct Day {
    
    let identifier: String
    var tripIdentifier: String?
    var text: String
    var image: Image
    
    init(identifier: String, tripIdentifier: String?, text: String, image: Image) {
        self.identifier = identifier
        self.tripIdentifier = tripIdentifier
        self.text = text
        self.image = image
    }
    
    init(text: String, image: Image) {
        self.identifier = NSUUID().UUIDString
        self.text = text
        self.image = image
    }
}

public struct Image {
    
    let name: String
    let date: NSDate
    let latitude: Double
    let longitude: Double
    
}

public struct Trip {
    
    let identifier: String
    var name: String
    var placeholderImageName: String? = nil

    init(name: String) {
        self.identifier = NSUUID().UUIDString
        self.name = name
    }
    
    init(identifier: String, name: String, placeholderImageName: String?) {
        self.identifier = identifier
        self.name = name
        self.placeholderImageName = placeholderImageName
    }
}

extension Day : Equatable {}

public func ==(lhs: Day, rhs: Day) -> Bool {
    return lhs.identifier == rhs.identifier
}

extension Image : Equatable {}

public func ==(lhs: Image, rhs: Image) -> Bool {
    return
            lhs.date == rhs.date &&
            lhs.name == rhs.name &&
            lhs.latitude == rhs.latitude &&
            lhs.longitude == rhs.longitude
}

extension Trip: Equatable {}

public func ==(lhs: Trip, rhs: Trip) -> Bool {
    return lhs.identifier == rhs.identifier
}