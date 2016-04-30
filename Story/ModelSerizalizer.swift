//
//  ModelSerizalizer.swift
//  Story
//
//  Created by COBI on 25.04.16.
//
//

import Foundation
import Photos

extension Trip {
    
    static func fromDictionary(dict: [String : AnyObject]) -> Trip? {
        if  let identifier = dict["identifier"] as? String,
            let creationDate = dict["creationDate"] as? NSDate,
            let name = dict["name"] as? String {
            return Trip(identifier: identifier, creationDate: creationDate, name: name)
        }
        return nil
    }
    
    func toDictionary() -> [String : AnyObject] {
        return [
            "identifier" : identifier,
            "creationDate" : creationDate,
            "name" : name
        ]
    }
}

extension Day {
    
    static func fromDictionary(dict: [String : AnyObject]) -> Day? {
        let date = dict["date"] as? NSDate
        let image = dict["image"] as? String
        let thumbnail = dict["thumbnail"] as? String
        let text = dict["text"] as? String
        let latitude = dict["latitude"] as? Double
        let longitude = dict["longitude"] as? Double
        let livePhoto = dict["livePhoto"] as? PHLivePhoto
        
        if  let identifier = dict["identifier"] as? String,
            let tripIdentifier = dict["tripIdentifier"] as? String?,
            let creationDate = dict["creationDate"] as? NSDate{
            
            var imageRef: Image? = nil
            if let anImage = image, aThumbnail = thumbnail, aDate = date {
                imageRef = Image(name: anImage, thumbnailName: aThumbnail, date: aDate, latitude: latitude, longitude: longitude, livePhoto: livePhoto)
            }
            return Day(identifier: identifier, creationDate: creationDate, tripIdentifier: tripIdentifier, text: text, image: imageRef)
        }
        return nil
    }
    
    func toDictionary() -> [String : AnyObject] {
        return [
            "identifier" : identifier,
            "creationDate" : creationDate,
            "tripIdentifier" : (tripIdentifier == nil ? NSNull() : tripIdentifier!),
            "date" : (image?.date == nil ? NSNull() : image!.date),
            "image" : (image?.name == nil ? NSNull() : image!.name),
            "thumbnail" : (image?.thumbnailName == nil ? NSNull() : image!.thumbnailName),
            "text" : (text == nil ? NSNull() : text!),
            "latitude" : (image?.latitude == nil ? NSNull() : image!.latitude!),
            "longitude" : (image?.longitude == nil ? NSNull() : image!.longitude!),
            "livePhoto" : (image?.livePhoto == nil ? NSNull() : image!.livePhoto!)
        ]
    }
    
}