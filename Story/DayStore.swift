//
//  DayStore.swift
//  Story
//
//  Created by COBI on 25.04.16.
//
//

import Foundation

public class DayStore {
    
    static private let userDefaultsDaysKey = "days"
    
    public let trip: Trip
    public var days: [Day] = []
    public var observers = NSHashTable.weakObjectsHashTable()
    
    init(trip: Trip) {
        self.trip = trip
    }
    
    public func storeDay(day: Day) {
        let oldIndex = days.indexOf(day)
        
        var aDay = day
        aDay.tripIdentifier = trip.identifier
        
        if let index = oldIndex {
            days[index] = aDay
            notifyObserver() { $0.didUpdateDay(aDay, atIndex: index) }
        } else {
            days.append(aDay)
            let index = days.count
            notifyObserver() { $0.didInsertDay(aDay, atIndex: index) }
        }
    }
    
    public func removeDay(day: Day) {
        if let index = days.indexOf(day) {
            days.removeAtIndex(index)
            notifyObserver() { $0.didRemoveDay(day, fromIndex: index) }
        }
    }
    
    public func load() {
        let data = NSUserDefaults.standardUserDefaults().objectForKey(DayStore.userDefaultsDaysKey)
        if let data = data as? NSData {
            let value = NSKeyedUnarchiver.unarchiveObjectWithData(data)
            
            guard let dayList = value as? [[String: AnyObject]] else {
                return
            }
            
            for dayDict in dayList {
                if let day = Day.fromDictionary(dayDict) where day.tripIdentifier == trip.identifier {
                    days.append(day)
                }
            }
        }
    }
    
    public func save() {
        var value: [[String: AnyObject]] = []
        for day in days {
            value.append(day.toDictionary())
        }
        let data = NSKeyedArchiver.archivedDataWithRootObject(value)
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: DayStore.userDefaultsDaysKey)
    }
    
    func reset() {
        days = []
    }
    
    static func delete() {
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: userDefaultsDaysKey)
    }
    
    private func notifyObserver(block: DayStoreObserver -> Void) {
        for observer in observers.copy().objectEnumerator() {
            if let anObserver = observer as? DayStoreObserver {
                block(anObserver)
            }
        }
    }
}

protocol DayStoreObserver {
    
    func didInsertDay(day: Day, atIndex index: Int)
    
    func didUpdateDay(day: Day, atIndex index: Int)
    
    func didRemoveDay(day: Day, fromIndex index: Int)
    
}

extension DayStore {
    
    func loadDemoDataIfNeeded() {
        if days.count == 0 {
            let image1 = ImageStore.storeImage(NSBundle.mainBundle().URLForResource("cinque1", withExtension: "jpg")!)!
            let day1 = Day(text: "Lorem ipsum I", image: image1)
            storeDay(day1)
            
            let image2 = ImageStore.storeImage(NSBundle.mainBundle().URLForResource("cinque2", withExtension: "jpg")!)!
            let day2 = Day(text: "Lorem ipsum II", image: image2)
            storeDay(day2)
        }
    }
}
