//
//  ImageStore.swift
//  Story
//
//  Created by COBI on 20.04.16.
//
//

import Foundation
import UIKit
import ImageIO

public class ImageStore {
    
    private static let basePath = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
    
    public static func loadImage(image: Image) -> UIImage? {
        let imageURL = basePath.URLByAppendingPathComponent(image.name)
        if let imageData = NSData(contentsOfURL: imageURL) {
            return UIImage(data: imageData)
        }
        return nil
    }
    
    public static func storeImage(image: NSURL) -> Image? {
        guard let pathExtension = image.pathExtension else { return nil }
        let imageName = "\(NSUUID().UUIDString).\(pathExtension)"
        let imageURL = basePath.URLByAppendingPathComponent(imageName)
        
        do {
            try NSFileManager.defaultManager().copyItemAtURL(image, toURL: imageURL)
            
            if let imageData = NSData(contentsOfURL: imageURL),
                   date = getImageDate(imageData),
                   location = getImageLocation(imageData) {
                return Image(name: imageName, date: date, latitude: location.latitude, longitude: location.longitude)
            }
        } catch let e as NSError {
            print(e)
        }
        
        return nil
    }
    
}

extension ImageStore {

    static func getImageDate(imageData: NSData) -> NSDate? {
        guard let gpsInfo = getImageGPSMetadata(imageData) else {
            return nil
        }
        
        guard let dateString = gpsInfo[kCGImagePropertyGPSDateStamp as String] as? String else {
            return nil
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy:MM:dd"
        return dateFormatter.dateFromString(dateString)
    }
    
    static func getImageLocation(imageData: NSData) -> (latitude: Double, longitude: Double)? {
        guard let gpsInfo = getImageGPSMetadata(imageData) else {
            return nil
        }
        
        guard let latitude = gpsInfo[kCGImagePropertyGPSLatitude as String] as? Double,
              let longitude = gpsInfo[kCGImagePropertyGPSLongitude as String] as? Double else {
            return nil
        }
        
        return (latitude: latitude, longitude: longitude)
    }
    
    private static func getImageGPSMetadata(imageData: NSData) -> [String : AnyObject]? {
        guard let sourceRef = CGImageSourceCreateWithData(imageData, nil) else {
            return nil
        }
        
        guard let properties = CGImageSourceCopyPropertiesAtIndex(sourceRef, 0, nil) as NSDictionary? else {
            return nil
        }
        
        guard let gpsInfo = properties[kCGImagePropertyGPSDictionary as String] as? [String : AnyObject] else {
            return nil
        }
        
        return gpsInfo
    }
}