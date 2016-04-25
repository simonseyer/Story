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
    
    public var observers = NSHashTable.weakObjectsHashTable()
    
    public func storeTrip(trip: Trip) {
        let oldIndex = trips.indexOf(trip)
        
        _trips[trip.identifier] = trip
        if let index = oldIndex {
            notifyObserver() { $0.didUpdateTrip(trip, atIndex: index) }
        } else {
            let index = trips.indexOf(trip)!
            notifyObserver() { $0.didInsertTrip(trip, atIndex: index) }
        }
    }
    
    public func removeTrip(trip: Trip) {
        if let index = trips.indexOf(trip) {
            _trips.removeValueForKey(trip.identifier)
            notifyObserver() { $0.didRemoveTrip(trip, fromIndex: index) }
        }
    }
    
    public func load() {
        let data = NSUserDefaults.standardUserDefaults().objectForKey(TripStore.userDefaultsTripKey)
        if let data = data as? NSData {
            let value = NSKeyedUnarchiver.unarchiveObjectWithData(data)
            
            guard let tripList = value as? [[String: AnyObject]] else {
                return
            }
            
            for tripDict in tripList {
                if let trip = Trip.fromDictionary(tripDict) {
                    _trips[trip.identifier] = trip
                }
            }
        }
    }
    
    public func save() {
        var value: [[String: AnyObject]] = []
        for trip in _trips.values {
            value.append(trip.toDictionary())
        }
        let data = NSKeyedArchiver.archivedDataWithRootObject(value)
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
    
    func didUpdateTrip(trip: Trip, atIndex index: Int)
    
    func didRemoveTrip(trip: Trip, fromIndex index: Int)
    
}

extension TripStore {
    
    func loadDemoDataIfNeeded() {
        if trips.count == 0 {
            let trip = Trip(name: "Lorem")
            storeTrip(trip)
        }
    }
}


