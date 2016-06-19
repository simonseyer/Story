//
//  DayStore.swift
//  Story
//
//  Created by COBI on 25.04.16.
//
//

import Foundation

public class DayStore {
    
    private let tripStore: TripStore
    public let trip: Trip
    public var days: [Day] {
        if let days = tripStore.days[trip] {
            return Array(days.values).sorted { (aDay, anotherDay) -> Bool in
                return DayStore.isOrdered(aDay, anotherDay: anotherDay)
            }
        }
        return []
    }
    public var observers = HashTable<AnyObject>.weakObjects()
    
    init(tripStore: TripStore, trip: Trip) {
        self.tripStore = tripStore
        self.trip = trip
    }
    
    public func storeDay(_ day: Day) {
        let oldIndex = days.index(of: day)
        
        var aDay = day
        aDay.tripIdentifier = trip.identifier
        
        var _days = tripStore.days[trip]
        if (_days == nil) {
            _days = [:]
        }
        _days![day.identifier] = aDay
        tripStore.days[trip] = _days
        
        let index = days.index(of: day)!
        if let oldIndex = oldIndex {
            notifyObserver() { $0.didUpdateDay(aDay, fromIndex: oldIndex, toIndex: index) }
        } else {
            notifyObserver() { $0.didInsertDay(aDay, atIndex: index) }
        }
    }
    
    public func removeDay(_ day: Day) {
        if var _days = tripStore.days[trip], let index = days.index(of: day) {
            _days.removeValue(forKey: day.identifier)
            notifyObserver() { $0.didRemoveDay(day, fromIndex: index) }
            tripStore.days[trip] = _days
        }
    }

    private func notifyObserver(_ block: (DayStoreObserver) -> Void) {
        for observer in observers.copy().objectEnumerator() {
            if let anObserver = observer as? DayStoreObserver {
                block(anObserver)
            }
        }
    }
    
    static func isOrdered(_ aDay: Day , anotherDay: Day) -> Bool {
        if let aDate = aDay.image?.date {
            if let anotherDate = anotherDay.image?.date {
                return aDate <= anotherDate
            } else {
                return true
            }
        } else {
            if anotherDay.image != nil {
                return false
            } else {
                return aDay.creationDate <= anotherDay.creationDate
            }
        }
    }

}

protocol DayStoreObserver: class {
    
    func didInsertDay(_ day: Day, atIndex index: Int)
    
    func didUpdateDay(_ day: Day, fromIndex: Int, toIndex: Int)
    
    func didRemoveDay(_ day: Day, fromIndex index: Int)
    
}

public func <=(lhs: Date, rhs: Date) -> Bool {
    let comparison = lhs.compare(rhs)
    return comparison == .orderedAscending || comparison == .orderedSame
}

