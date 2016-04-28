//
//  Day.swift
//  Story
//
//  Created by COBI on 20.04.16.
//
//

import Foundation
import Photos

public struct Day {
    
    let identifier: String
    var tripIdentifier: String?
    var text: String?
    var image: Image?
    
    init(identifier: String, tripIdentifier: String?, text: String?, image: Image?) {
        self.identifier = identifier
        self.tripIdentifier = tripIdentifier
        self.text = text
        self.image = image
    }
    
    init(text: String?, image: Image?) {
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
    let livePhoto: PHLivePhoto?
    
}

public struct Trip {
    
    let identifier: String
    var name: String

    init(name: String) {
        self.identifier = NSUUID().UUIDString
        self.name = name
    }
    
    init(identifier: String, name: String) {
        self.identifier = identifier
        self.name = name
    }
}

extension Day: Equatable {}

public func ==(lhs: Day, rhs: Day) -> Bool {
    return lhs.identifier == rhs.identifier
}

extension Day: Hashable {
    
    public var hashValue: Int {
        return identifier.hashValue
    }
}

extension Image: Equatable {}

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

extension Trip: Hashable {

    public var hashValue: Int {
        return identifier.hashValue
    }
}

