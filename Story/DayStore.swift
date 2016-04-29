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
            return Array(days.values).sort { (aDay, anotherDay) -> Bool in
                return DayStore.isOrdered(aDay, anotherDay: anotherDay)
            }
        }
        return []
    }
    public var observers = NSHashTable.weakObjectsHashTable()
    
    init(tripStore: TripStore, trip: Trip) {
        self.tripStore = tripStore
        self.trip = trip
    }
    
    public func storeDay(day: Day) {
        let oldIndex = days.indexOf(day)
        
        var aDay = day
        aDay.tripIdentifier = trip.identifier
        
        var _days = tripStore.days[trip]
        if (_days == nil) {
            _days = [:]
        }
        _days![day.identifier] = aDay
        tripStore.days[trip] = _days
        
        let index = days.indexOf(day)!
        if let oldIndex = oldIndex {
            notifyObserver() { $0.didUpdateDay(aDay, fromIndex: oldIndex, toIndex: index) }
        } else {
            notifyObserver() { $0.didInsertDay(aDay, atIndex: index) }
        }
    }
    
    public func removeDay(day: Day) {
        if var _days = tripStore.days[trip], let index = days.indexOf(day) {
            _days.removeValueForKey(day.identifier)
            notifyObserver() { $0.didRemoveDay(day, fromIndex: index) }
            tripStore.days[trip] = _days
        }
    }

    private func notifyObserver(block: DayStoreObserver -> Void) {
        for observer in observers.copy().objectEnumerator() {
            if let anObserver = observer as? DayStoreObserver {
                block(anObserver)
            }
        }
    }
    
    static func isOrdered(aDay: Day , anotherDay: Day) -> Bool {
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
                return true
            }
        }
    }

}

protocol DayStoreObserver {
    
    func didInsertDay(day: Day, atIndex index: Int)
    
    func didUpdateDay(day: Day, fromIndex: Int, toIndex: Int)
    
    func didRemoveDay(day: Day, fromIndex index: Int)
    
}

public func <=(lhs: NSDate, rhs: NSDate) -> Bool {
    let comparison = lhs.compare(rhs)
    return comparison == .OrderedAscending || comparison == .OrderedSame
}

