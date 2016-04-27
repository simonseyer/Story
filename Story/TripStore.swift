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
    var days: [Trip : [String : Day]] = [:]
    public var trips: [Trip] {
        return Array(_trips.values)
    }
    
    public var observers = NSHashTable.weakObjectsHashTable()
    
    public func storeTrip(trip: Trip) {
        let oldIndex = trips.indexOf(trip)
        
        _trips[trip.identifier] = trip
        let index = trips.indexOf(trip)!
        if let oldIndex = oldIndex {
            notifyObserver() { $0.didUpdateTrip(trip, fromIndex: oldIndex, toIndex: index) }
        } else {
            notifyObserver() { $0.didInsertTrip(trip, atIndex: index) }
        }
    }
    
    public func removeTrip(trip: Trip) {
        if let index = trips.indexOf(trip) {
            _trips.removeValueForKey(trip.identifier)
            notifyObserver() { $0.didRemoveTrip(trip, fromIndex: index) }
        }
    }
    
    public func dayStoreForTrip(trip: Trip) -> DayStore {
        return DayStore(tripStore: self, trip: trip)
    }
    
    public func load() {
        let data = NSUserDefaults.standardUserDefaults().objectForKey(TripStore.userDefaultsTripKey)
        if let data = data as? NSData {
            let value = NSKeyedUnarchiver.unarchiveObjectWithData(data)
            
            guard let valueDict = value as? [String: AnyObject] else {
                return
            }
            
            if let tripList = valueDict["trips"] as? [[String: AnyObject]] {
                for tripDict in tripList {
                    if let trip = Trip.fromDictionary(tripDict) {
                        _trips[trip.identifier] = trip
                    }
                }
            }
            
            if let dayList = valueDict["days"] as? [[String: AnyObject]] {
                for dayDict in dayList {
                    if let day = Day.fromDictionary(dayDict), tripIdentifier = day.tripIdentifier, trip = _trips[tripIdentifier] {
                        if days[trip] == nil {
                            days[trip] = [:]
                        }
                        days[trip]![day.identifier] = day
                    }
                }
            }
        }
    }
    
    public func save() {
        var tripList: [[String: AnyObject]] = []
        for trip in _trips.values {
            tripList.append(trip.toDictionary())
        }
        
        var dayList: [[String: AnyObject]] = []
        for (_, day) in days.values.flatten() {
            dayList.append(day.toDictionary())
        }
        
        let data = NSKeyedArchiver.archivedDataWithRootObject(["trips" : tripList, "days" : dayList])
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: TripStore.userDefaultsTripKey)
    }
    
    func reset() {
        _trips = [:]
    }
    
    static func delete() {
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: userDefaultsTripKey)
    }
    
    private func notifyObserver(block: TripStoreObserver -> Void) {
        for observer in observers.copy().objectEnumerator() {
            if let anObserver = observer as? TripStoreObserver {
                block(anObserver)
            }
        }
    }
}

protocol TripStoreObserver {
    
    func didInsertTrip(trip: Trip, atIndex index: Int)
    
    func didUpdateTrip(trip: Trip, fromIndex: Int, toIndex: Int)
    
    func didRemoveTrip(trip: Trip, fromIndex index: Int)
    
}

extension TripStore {
    
    func loadDemoDataIfNeeded() {
        if trips.count == 0 {
            let trip = Trip(name: "Lorem")
            storeTrip(trip)
            
            let dayStore = dayStoreForTrip(trip)
            
            let image1 = ImageStore.storeImage(NSBundle.mainBundle().URLForResource("cinque1", withExtension: "jpg")!)!
            let day1 = Day(text: "Lorem ipsum I", image: image1)
            dayStore.storeDay(day1)
            
            let image2 = ImageStore.storeImage(NSBundle.mainBundle().URLForResource("cinque2", withExtension: "jpg")!)!
            let day2 = Day(text: "Lorem ipsum II", image: image2)
            dayStore.storeDay(day2)
        }
    }
}


