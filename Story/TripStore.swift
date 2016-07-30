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
    private var dayStoreCache = [Trip : DayStore]()
    public var trips: [Trip] {
        return Array(_trips.values).sorted { (aTrip, anotherTrip) -> Bool in
            if let aFirstDay = days[aTrip]?.first?.1 {
                if let anotherFirstDay = days[anotherTrip]?.first?.1 {
                    return !DayStore.isOrdered(aFirstDay, anotherDay: anotherFirstDay)
                } else {
                    return false
                }
            } else {
                if days[anotherTrip]?.first != nil {
                    return true
                } else {
                    return !(aTrip.creationDate <= anotherTrip.creationDate)
                }
            }
        }
    }
    
    public var observers = HashTable<AnyObject>.weakObjects()
    
    public func storeTrip(_ trip: Trip) {
        let oldIndex = trips.index(of: trip)
        
        _trips[trip.identifier] = trip
        let index = trips.index(of: trip)!
        if let oldIndex = oldIndex {
            notifyObserver() { $0.didUpdateTrip(trip, fromIndex: oldIndex, toIndex: index) }
        } else {
            notifyObserver() { $0.didInsertTrip(trip, atIndex: index) }
        }
    }
    
    public func removeTrip(_ trip: Trip) {
        if let index = trips.index(of: trip) {
            _trips.removeValue(forKey: trip.identifier)
            notifyObserver() { $0.didRemoveTrip(trip, fromIndex: index) }
        }
    }
    
    public func dayStoreForTrip(_ trip: Trip) -> DayStore {
        if dayStoreCache[trip] == nil {
            dayStoreCache[trip] = DayStore(tripStore: self, trip: trip)
        }
        return dayStoreCache[trip]!
    }
    
    public func load() {
        let data = UserDefaults.standard.object(forKey: TripStore.userDefaultsTripKey)
        if let data = data as? Data {
            let value = NSKeyedUnarchiver.unarchiveObject(with: data)
            
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
                    if let day = Day.fromDictionary(dayDict), let tripIdentifier = day.tripIdentifier, let trip = _trips[tripIdentifier] {
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
        
        let data = NSKeyedArchiver.archivedData(withRootObject: ["trips" : tripList, "days" : dayList])
        UserDefaults.standard.set(data, forKey: TripStore.userDefaultsTripKey)
    }
    
    func reset() {
        _trips = [:]
    }
    
    static func delete() {
        UserDefaults.standard.setValue(nil, forKey: userDefaultsTripKey)
    }
    
    private func notifyObserver(_ block: (TripStoreObserver) -> Void) {
        for observer in observers.copy().objectEnumerator() {
            if let anObserver = observer as? TripStoreObserver {
                block(anObserver)
            }
        }
    }
}

protocol TripStoreObserver {
    
    func didInsertTrip(_ trip: Trip, atIndex index: Int)
    
    func didUpdateTrip(_ trip: Trip, fromIndex: Int, toIndex: Int)
    
    func didRemoveTrip(_ trip: Trip, fromIndex index: Int)
    
}

extension TripStore {
    
    func loadDemoDataIfNeeded() {
        if trips.count == 0 {
            DispatchQueue.main.async {
                let tutorialTrip = Trip(name: "The first Story")
                
                let dayStore = self.dayStoreForTrip(tutorialTrip)
                
                let image = ImageStore.storeImage(Bundle.main.urlForResource("nw1", withExtension: "JPG")!)
                let text = "I love to travel and to share my stories. Look above — a lonely bike. But more important, it's my first moment in a new country: Norway"
                dayStore.storeDay(Day(text: text, image: image))
                
                self.storeTrip(tutorialTrip)
                
                ImageStore.storeImage(Bundle.main.urlForResource("nw2", withExtension: "JPG")!) { image in
                    let text = "Capturing your thoughts along with the image lets you and your friends revive the moment when you looked into the distance ..."
                    dayStore.storeDay(Day(text: text, image: image))
                }
                
                ImageStore.storeImage(Bundle.main.urlForResource("nw3", withExtension: "JPG")!) { image in
                    let text = "... or lived on a razor-edge"
                    dayStore.storeDay(Day(text: text, image: image))
                }
                
                ImageStore.storeImage(Bundle.main.urlForResource("nw4", withExtension: "JPG")!) { image in
                    let text = "Dive deep into your memories by pressing on the image or on the map. Try it now, jump into the waterfall!"
                    dayStore.storeDay(Day(text: text, image: image))
                }
                
                ImageStore.storeImage(Bundle.main.urlForResource("nw5", withExtension: "JPG")!) { image in
                    let text = "It's time to go back and build your own story. It is as simple as editing your personal Story Book"
                    dayStore.storeDay(Day(text: text, image: image))
                }
            }
        }
    }
}


