//
//  ModelSerizalizer.swift
//  Story
//
//  Created by COBI on 25.04.16.
//
//

import Foundation

extension Trip {
    
    static func fromDictionary(dict: [String : AnyObject]) -> Trip? {
        if  let identifier = dict["identifier"] as? String,
            let name = dict["name"] as? String,
            let placeholderImageName = dict["placeholderImageName"] as? String? {
            return Trip(identifier: identifier, name: name, placeholderImageName: placeholderImageName)
        }
        return nil
    }
    
    func toDictionary() -> [String : AnyObject] {
        return [
            "identifier" : identifier,
            "name" : name,
            "placeholderImageName" : (placeholderImageName == nil ? NSNull() : placeholderImageName!)
        ]
    }
}

extension Day {
    
    static func fromDictionary(dict: [String : AnyObject]) -> Day? {
        if  let identifier = dict["identifier"] as? String,
            let tripIdentifier = dict["tripIdentifier"] as? String?,
            let date = dict["date"] as? NSDate?,
            let image = dict["image"] as? String?,
            let text = dict["text"] as? String?,
            let latitude = dict["latitude"] as? Double?,
            let longitude = dict["longitude"] as? Double? {
            
            var imageRef: Image? = nil
            if let image = image, date = date, latitude = latitude, longitude = longitude {
                imageRef = Image(name: image, date: date, latitude: latitude, longitude: longitude)
            }
            return Day(identifier: identifier, tripIdentifier: tripIdentifier, text: text, image: imageRef)
        }
        return nil
    }
    
    func toDictionary() -> [String : AnyObject] {
        return [
            "identifier" : identifier,
            "tripIdentifier" : (tripIdentifier == nil ? NSNull() : tripIdentifier!),
            "date" : (image?.date == nil ? NSNull() : image!.date),
            "image" : (image?.name == nil ? NSNull() : image!.name),
            "text" : (text == nil ? NSNull() : text!),
            "latitude" : (image?.latitude == nil ? NSNull() : image!.latitude),
            "longitude" : (image?.longitude == nil ? NSNull() : image!.longitude)
        ]
    }
    
}