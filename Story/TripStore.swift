//
//  ModelStore.swift
//  Story
//
//  Created by COBI on 20.04.16.
//
//

import Foundation
import UIKit

public class TripStore {
    
    static private let userDefaultsTripKey = "trips"
    
    private var _trips: [String : Trip] = [:]
    public var trips: [Trip] {
        return Array(_trips.values)
    }
    
    public func storeTrip(trip: Trip) {
        _trips[trip.identifier] = trip
    }
    
    public func load() {
        let value = NSUserDefaults.standardUserDefaults().valueForKey(TripStore.userDefaultsTripKey)
        
        guard let tripList = value as? [String: [String : AnyObject]] else {
            return
        }
        
        for (identifier, tripDict) in tripList {
            if let trip = Trip.fromDictionary(tripDict) {
                _trips[identifier] = trip
            }
        }
    }
    
    public func save() {
        var value: [String: [String : AnyObject]] = [:]
        for (identifier, trip) in _trips {
            value[identifier] = trip.toDictionary()
        }
        NSUserDefaults.standardUserDefaults().setValue(value, forKey: TripStore.userDefaultsTripKey)
    }
    
    func reset() {
        _trips = [:]
    }
    
    static func delete() {
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: userDefaultsTripKey)
    }
    
}

extension TripStore {
    
    func loadDemoDataIfNeeded() {
        if trips.count == 0 {
            let image1 = ImageStore.storeImage(NSBundle.mainBundle().URLForResource("cinque1", withExtension: "jpg")!)!
            let day1 = Day(text: "Lorem ipsum I", image: image1)
            let image2 = ImageStore.storeImage(NSBundle.mainBundle().URLForResource("cinque2", withExtension: "jpg")!)!
            let day2 = Day(text: "Lorem ipsum II", image: image2)
            let trip = Trip(identifier: NSUUID().UUIDString, name: "Lorem", days: [day1, day2])
            storeTrip(trip)
        }
    }
}

extension Trip {
    
    static func fromDictionary(dict: [String : AnyObject]) -> Trip? {
        if  let identifier = dict["identifier"] as? String,
            let name = dict["name"] as? String,
            let days = dict["days"] as? [[String : AnyObject]] {
            let dayList = days.map({ Day.fromDictionary($0) }).flatMap({ $0 })
            return Trip(identifier: identifier, name: name, days: dayList)
        }
        return nil
    }
    
    func toDictionary() -> [String : AnyObject] {
        return [
            "identifier" : identifier,
            "name" : name,
            "days" : days.map({ $0.toDictionary() })
        ]
    }
}

extension Day {
    
    static func fromDictionary(dict: [String : AnyObject]) -> Day? {
        if  let date = dict["date"] as? NSDate,
            let image = dict["image"] as? String,
            let text = dict["text"] as? String,
            let latitude = dict["latitude"] as? Float,
            let longitude = dict["longitude"] as? Float {
            return Day(text: text, image: Image(name: image, date: date, latitude: latitude, longitude: longitude))
        }
        return nil
    }
    
    func toDictionary() -> [String : AnyObject] {
        return [
            "date" : image.date,
            "image" : image.name,
            "text" : text,
            "latitude" : image.latitude,
            "longitude" : image.longitude
        ]
    }
    
}
