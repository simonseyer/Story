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

public class ImageStore {
    
    private static let basePath = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
    
    public static func loadImage(image: Image, completion: UIImage? -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            let loadedImage = loadImage(image)
            dispatch_async(dispatch_get_main_queue()) {
                completion(loadedImage)
            }
        }
    }
    
    public static func loadImage(image: Image) -> UIImage? {
        let imageURL = basePath.URLByAppendingPathComponent(image.name)
        if let imageData = NSData(contentsOfURL: imageURL) {
            return UIImage(data: imageData)
        }
        return nil
    }
    
    public static func storeImage(image: NSURL, completion: Image? -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            let storedImage = storeImage(image)
            dispatch_async(dispatch_get_main_queue()) {
                completion(storedImage)
            }
        }
    }
    
    public static func storeImage(imageURL: NSURL) -> Image? {
        let pathExtension = imageURL.pathExtension ?? "jpeg"
        let imageName = "\(NSUUID().UUIDString).\(pathExtension)"
        let targetImageURL = basePath.URLByAppendingPathComponent(imageName)
        
        do {
            try NSFileManager.defaultManager().copyItemAtURL(imageURL, toURL: targetImageURL)
            
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
    
    public static func storeImage(image: UIImage, assetRef: NSURL, completion: Image? -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            let storedImage = storeImage(image, assetRef: assetRef)
            dispatch_async(dispatch_get_main_queue()) {
                completion(storedImage)
            }
        }
    }
    
    public static func storeImage(image: UIImage, assetRef: NSURL) -> Image? {
        let assetResult = PHAsset.fetchAssetsWithALAssetURLs([assetRef], options: nil)
        guard let asset = assetResult.firstObject as? PHAsset
            where asset.creationDate != nil && asset.location != nil
        else {
            return nil
        }
        
        guard let imageData = UIImageJPEGRepresentation(image, 1) else {
            return nil
        }
        
        let pathExtension = assetRef.pathExtension ?? "jpeg"
        let imageName = "\(NSUUID().UUIDString).\(pathExtension)"
        let targetImageURL = basePath.URLByAppendingPathComponent(imageName)
        
        do {
            try imageData.writeToURL(targetImageURL, options: NSDataWritingOptions())
        } catch let e as NSError {
            print(e)
            return nil
        }
        
        let coordinate = asset.location!.coordinate
        return Image(name: imageName, date: asset.creationDate!, latitude: coordinate.latitude, longitude: coordinate.longitude)
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