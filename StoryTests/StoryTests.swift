//
//  StoryTests.swift
//  StoryTests
//
//  Created by COBI on 20.04.16.
//
//

import XCTest

@testable import Story

class StoryTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        TripStore.delete()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testModelStore() {
        let day = Day(date: NSDate(), image: "test", text: "test", latitude: 0, longitude: 0)
        let trip = Trip(identifier: NSUUID().UUIDString, name: "Trip Test", days: [day])
        
        let store = TripStore()
        store.storeTrip(trip)
        store.save()
        store.reset()
        store.load()
        
        let trips = store.trips
        
        XCTAssertEqual(trips.count, 1)
        
        guard trips.count > 0 else { return }
        
        let tripII = trips[0]
        XCTAssertEqual(trip, tripII)
    }
    
}
