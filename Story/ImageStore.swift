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
import Photos
import CoreLocation

public class ImageStore {
    
    private static let basePath = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
    private static var locationManager: OneShotLocationManager?
    
    public static func loadImage(image: Image) -> UIImage? {
        let imageURL = basePath.URLByAppendingPathComponent(image.name)
        if let imageData = NSData(contentsOfURL: imageURL) {
            return UIImage(data: imageData)
        }
        return nil
    }

}

// Storing photos
extension ImageStore {
    
    // For images with embedded metadata (e.g. bundled images)
    public static func storeImage(imageURL: NSURL) -> Image? {
        let pathExtension = imageURL.pathExtension ?? "jpeg"
        let imageName = "\(NSUUID().UUIDString).\(pathExtension)"
        let targetImageURL = basePath.URLByAppendingPathComponent(imageName)
        
        do {
            try NSFileManager.defaultManager().copyItemAtURL(imageURL, toURL: targetImageURL)
            
            if let imageData = NSData(contentsOfURL: imageURL),
                gpsInfo = getImageGPSMetadata(imageData),
                date = getImageDate(gpsInfo),
                location = getImageLocation(gpsInfo) {
                return Image(name: imageName, date: date, latitude: location.latitude, longitude: location.longitude, livePhoto: nil)
            }
        } catch let e as NSError {
            print(e)
        }
        
        return nil
    }
    
    
    // For images from the photo library with an associated PHAsset
    public static func storeImage(image: UIImage, assetRef: NSURL, livePhoto: PHLivePhoto? = nil) -> Image? {
        let assetResult = PHAsset.fetchAssetsWithALAssetURLs([assetRef], options: nil)
        
        guard let asset = assetResult.firstObject as? PHAsset
            where asset.creationDate != nil && asset.location != nil
            else {
                return nil
        }
        
        guard let imageName = storeImage(image) else {
            return nil
        }
        
        let coordinate = asset.location!.coordinate
        return Image(name: imageName, date: asset.creationDate!, latitude: coordinate.latitude, longitude: coordinate.longitude, livePhoto: livePhoto)
    }
    
    // For images from the camera (current date and location is used)
    public static func storeImage(image: UIImage, completion: Image? -> Void){
        let date = NSDate()
        
        if locationManager != nil {
            print("Duplicate use of location manager")
            completion(nil)
        }
        
        locationManager = OneShotLocationManager()
        locationManager!.fetchWithCompletion { (location, error) in
            locationManager = nil
            if let imageName = storeImage(image) {
                if let location = location?.coordinate {
                    let imageRef = Image(name: imageName, date: date, latitude: location.latitude, longitude: location.longitude, livePhoto: nil)
                    completion(imageRef)
                    return
                }
            }
            print(error)
            completion(nil)
        }
    }
}

// Convenience async functions
extension ImageStore {
    public static func loadImage(image: Image, completion: UIImage? -> Void) {
        Background.execute({ loadImage(image) }, completionBlock: completion)
    }
    
    public static func storeImage(image: NSURL, completion: Image? -> Void) {
        Background.execute({ storeImage(image) }, completionBlock: completion)
    }
    
    public static func storeImage(image: UIImage, assetRef: NSURL, livePhoto: PHLivePhoto? = nil, completion: Image? -> Void) {
        Background.execute({ storeImage(image, assetRef: assetRef, livePhoto: livePhoto) }, completionBlock: completion)
    }
}

// GPS metadata reader
extension ImageStore {

    static func getImageDate(gpsDict: [String : AnyObject]?) -> NSDate? {
        guard let gpsInfo = gpsDict else {
            return nil
        }
        
        guard let dateString = gpsInfo[kCGImagePropertyGPSDateStamp as String] as? String else {
            return nil
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy:MM:dd"
        return dateFormatter.dateFromString(dateString)
    }
    
    static func getImageLocation(gpsDict: [String : AnyObject]?) -> (latitude: Double, longitude: Double)? {
        guard let gpsInfo = gpsDict else {
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

// Store image helper
extension ImageStore {
    
    private static func storeImage(image: UIImage) -> String? {
        guard let imageData = UIImageJPEGRepresentation(image, 1) else {
            return nil
        }
        
        let imageName = "\(NSUUID().UUIDString).jpeg"
        let targetImageURL = basePath.URLByAppendingPathComponent(imageName)
        
        do {
            try imageData.writeToURL(targetImageURL, options: NSDataWritingOptions())
            return imageName
        } catch let e as NSError {
            print(e)
            return nil
        }
    }

}