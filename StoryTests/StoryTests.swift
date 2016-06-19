//
//  StoryTests.swift
//  StoryTests
//
//  Created by COBI on 20.04.16.
//
//

import XCTest

@testable import StoryBook

class StoryTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        TripStore.delete()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTripStore() {
        let day = Day(text: "test", image: Image(name: "test", thumbnailName:"test_thumb", date: Date(), latitude: 0, longitude: 0, livePhoto: nil))
        let trip = Trip(identifier: UUID().UUIDString, name: "Trip Test", days: [day])
        
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
        XCTAssertEqual(trip.days.count, 1)
        
        guard trip.days.count > 0 else { return }
        
        let dayII = trip.days[0]
        XCTAssertEqual(day, dayII)
    }
    
    func testImageStore() {
        let imageURL = Bundle.main().urlForResource("cinque1", withExtension: "jpg")
        
        let imageRef = ImageStore.storeImage(imageURL!)
        print(imageRef?.date)
        
        XCTAssertNotNil(imageRef)
        guard let ref = imageRef else { return }
        
        let image = ImageStore.loadImage(ref, thumbnail: false)
        XCTAssertNotNil(image)
    }
    
    func testImageMetadata() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        
        let imageURL = Bundle.main().urlForResource("cinque1", withExtension: "jpg")
        let imageDate = dateFormatter.date(from: "10.09.2013")
        let imageLatitude: Float = 44.107333
        let imageLongitude: Float = 9.725500
        let imageRef = ImageStore.storeImage(imageURL!)
        
        guard let ref = imageRef else { return }
        
        XCTAssertEqual(ref.date, imageDate)
        XCTAssertEqualWithAccuracy(ref.latitude, imageLatitude, accuracy: DBL_EPSILON)
        XCTAssertEqualWithAccuracy(ref.longitude, imageLongitude, accuracy: DBL_EPSILON)
    }
    
}
