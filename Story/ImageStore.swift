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
    
    public static func loadImage(image: Image, thumbnail: Bool) -> UIImage? {
        let imageURL = basePath.URLByAppendingPathComponent(thumbnail ? image.thumbnailName : image.name)
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
        if let imageData = NSData(contentsOfURL: imageURL),
            image = UIImage(data: imageData),
            gpsInfo = getImageGPSMetadata(imageData),
            date = getImageDate(gpsInfo),
            location = getImageLocation(gpsInfo) {
            
            guard let (imageName, thumbnailName) = storeImage(image) else {
                return nil
            }
            
            return Image(name: imageName, thumbnailName: thumbnailName, date: date, latitude: location.latitude, longitude: location.longitude, livePhoto: nil)
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
        
        guard let (imageName, thumbnailName) = storeImage(image) else {
            return nil
        }
        
        let coordinate = asset.location!.coordinate
        return Image(name: imageName, thumbnailName: thumbnailName, date: asset.creationDate!, latitude: coordinate.latitude, longitude: coordinate.longitude, livePhoto: livePhoto)
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
            
            let rotatedImage = normalizedImage(image)
            if let (imageName, thumbnailName) = storeImage(rotatedImage) {
                if let location = location?.coordinate {
                    let imageRef = Image(name: imageName, thumbnailName: thumbnailName, date: date, latitude: location.latitude, longitude: location.longitude, livePhoto: nil)
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
    public static func loadImage(image: Image, thumbnail: Bool, completion: UIImage? -> Void) {
        Background.execute({ loadImage(image, thumbnail: thumbnail) }, completionBlock: completion)
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
        
        guard let timeString = gpsInfo[kCGImagePropertyGPSTimeStamp as String] as? String else {
            return nil
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy:MM:dd:HH:mm:ss"
        return dateFormatter.dateFromString("\(dateString):\(timeString)")
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
    
    private static func storeImage(image: UIImage) -> (String, String)? {
        // Image
        guard let imageData = UIImageJPEGRepresentation(image, 1) else {
            return nil
        }
        
        let imageName = "\(NSUUID().UUIDString).jpeg"
        let targetImageURL = basePath.URLByAppendingPathComponent(imageName)
        
        do {
            try imageData.writeToURL(targetImageURL, options: NSDataWritingOptions())
        } catch let e as NSError {
            print(e)
            return nil
        }
        
        // Thumbnail
        let thumbnailImage = resizeImage(image, size: UIScreen.mainScreen().bounds.size)
        
        let thumbnailImageName = "\(NSUUID().UUIDString)-thumbnail.jpeg"
        let thumbnailImageURL = basePath.URLByAppendingPathComponent(thumbnailImageName)
        
        guard let thumbnailImageData = UIImageJPEGRepresentation(thumbnailImage, 1) else {
            return nil
        }
        
        do {
            try thumbnailImageData.writeToURL(thumbnailImageURL, options: NSDataWritingOptions())
        } catch let e as NSError {
            print(e)
            return nil
        }
        
        return (imageName, thumbnailImageName)
    }

    private static func resizeImage(image: UIImage, size: CGSize) -> (UIImage) {
        
        let xFactor = size.width / image.size.width
        let yFactor = size.height / image.size.height
        let factor = max(xFactor, yFactor)
        
        let newSize = CGSize(width: image.size.width * factor, height: image.size.height * factor)
        let newRect = CGRectIntegral(CGRectMake(0,0, newSize.width, newSize.height))
        let imageRef = image.CGImage
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        // Set the quality level to use when rescaling
        CGContextSetInterpolationQuality(context, .High)
        let flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height)
        
        CGContextConcatCTM(context, flipVertical)
        // Draw into the context; this scales the image
        CGContextDrawImage(context, newRect, imageRef)
        
        let newImageRef = CGBitmapContextCreateImage(context)! as CGImage
        let newImage = UIImage(CGImage: newImageRef)
        
        // Get the resized image from the context and a UIImage
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    private static func normalizedImage(image: UIImage) -> UIImage {
        if image.imageOrientation == .Up {
            return image
        }
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.drawInRect(CGRect(origin: CGPoint(x: 0, y: 0), size: image.size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return normalizedImage
    }
    
}