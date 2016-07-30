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
    
    private static let basePath = FileManager.default().urlsForDirectory(.documentDirectory, inDomains: .userDomainMask)[0]
    private static var locationManager: SingleLocationManager?
    
    public static func loadImage(_ image: Image, thumbnail: Bool) -> UIImage? {
        let imageURL = try! basePath.appendingPathComponent(thumbnail ? image.thumbnailName : image.name)
        if let imageData = try? Data(contentsOf: imageURL) {
            return UIImage(data: imageData)
        }
        return nil
    }

}

// Storing photos
extension ImageStore {
    
    // For images with embedded metadata (e.g. bundled images)
    public static func storeImage(_ imageURL: URL) -> Image? {
        if let imageData = try? Data(contentsOf: imageURL),
            image = UIImage(data: imageData),
            gpsInfo = getImageGPSMetadata(imageData),
            date = getImageDate(gpsInfo) {
            
            let location = getImageLocation(gpsInfo)
            
            guard let (imageName, thumbnailName) = storeImage(image) else {
                return nil
            }
            
            return Image(name: imageName, thumbnailName: thumbnailName, date: date, latitude: location?.latitude, longitude: location?.longitude, livePhoto: nil)
        }
        return nil
    }
    
    
    // For images from the photo library with an associated PHAsset
    public static func storeImage(_ image: UIImage, assetRef: URL, livePhoto: PHLivePhoto? = nil) -> Image? {
        let assetResult = PHAsset.fetchAssets(withALAssetURLs: [assetRef], options: nil)
        
        guard let asset = assetResult.firstObject
            where asset.creationDate != nil
            else {
                return nil
        }
        
        guard let (imageName, thumbnailName) = storeImage(image) else {
            return nil
        }
        
        let coordinate = asset.location?.coordinate
        return Image(name: imageName, thumbnailName: thumbnailName, date: asset.creationDate!, latitude: coordinate?.latitude, longitude: coordinate?.longitude, livePhoto: livePhoto)
    }
    
    // For images from the camera (current date and location is used)
    public static func storeImage(_ image: UIImage, completion: (Image?) -> Void){
        let date = Date()
        
        if locationManager != nil {
            print("Duplicate use of location manager")
            completion(nil)
        }
        
        locationManager = SingleLocationManager()
        locationManager!.fetchLocation { (location, error) in
            locationManager = nil
            
            let rotatedImage = normalizedImage(image)
            if let (imageName, thumbnailName) = storeImage(rotatedImage) {
                let location = location?.coordinate
                let imageRef = Image(name: imageName, thumbnailName: thumbnailName, date: date, latitude: location?.latitude, longitude: location?.longitude, livePhoto: nil)
                completion(imageRef)
                return
            }
            print(error)
            completion(nil)
        }
    }
}

// Convenience async functions
extension ImageStore {
    public static func loadImage(_ image: Image, thumbnail: Bool, completion: (UIImage?) -> Void) {
        Background.execute({ loadImage(image, thumbnail: thumbnail) }, completionBlock: completion)
    }
    
    public static func storeImage(_ image: URL, completion: (Image?) -> Void) {
        Background.execute({ storeImage(image) }, completionBlock: completion)
    }
    
    public static func storeImage(_ image: UIImage, assetRef: URL, livePhoto: PHLivePhoto? = nil, completion: (Image?) -> Void) {
        Background.execute({ storeImage(image, assetRef: assetRef, livePhoto: livePhoto) }, completionBlock: completion)
    }
}

// GPS metadata reader
extension ImageStore {

    static func getImageDate(_ gpsDict: [String : AnyObject]?) -> Date? {
        guard let gpsInfo = gpsDict else {
            return nil
        }
        
        guard let dateString = gpsInfo[kCGImagePropertyGPSDateStamp as String] as? String else {
            return nil
        }
        
        guard let timeString = gpsInfo[kCGImagePropertyGPSTimeStamp as String] as? String else {
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy:MM:dd:HH:mm:ss"
        return dateFormatter.date(from: "\(dateString):\(timeString)")
    }
    
    static func getImageLocation(_ gpsDict: [String : AnyObject]?) -> (latitude: Double, longitude: Double)? {
        guard let gpsInfo = gpsDict else {
            return nil
        }
        
        guard let latitude = gpsInfo[kCGImagePropertyGPSLatitude as String] as? Double,
              let longitude = gpsInfo[kCGImagePropertyGPSLongitude as String] as? Double else {
            return nil
        }
        
        return (latitude: latitude, longitude: longitude)
    }
    
    private static func getImageGPSMetadata(_ imageData: Data) -> [String : AnyObject]? {
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
    
    private static func storeImage(_ image: UIImage) -> (String, String)? {
        // Image
        guard let imageData = UIImageJPEGRepresentation(image, 1) else {
            return nil
        }
        
        let imageName = "\(UUID().uuidString).jpeg"
        let targetImageURL = try! basePath.appendingPathComponent(imageName)
        
        do {
            try imageData.write(to: targetImageURL, options: NSData.WritingOptions())
        } catch let e as NSError {
            print(e)
            return nil
        }
        
        // Thumbnail
        let thumbnailImage = resizeImage(image, size: UIScreen.main().bounds.size)
        
        let thumbnailImageName = "\(UUID().uuidString)-thumbnail.jpeg"
        let thumbnailImageURL = try! basePath.appendingPathComponent(thumbnailImageName)
        
        guard let thumbnailImageData = UIImageJPEGRepresentation(thumbnailImage, 1) else {
            return nil
        }
        
        do {
            try thumbnailImageData.write(to: thumbnailImageURL, options: NSData.WritingOptions())
        } catch let e as NSError {
            print(e)
            return nil
        }
        
        return (imageName, thumbnailImageName)
    }

    private static func resizeImage(_ image: UIImage, size: CGSize) -> (UIImage) {
        
        let xFactor = size.width / image.size.width
        let yFactor = size.height / image.size.height
        let factor = max(xFactor, yFactor)
        
        let newSize = CGSize(width: image.size.width * factor, height: image.size.height * factor)
        let newRect = CGRect(x: 0,y: 0, width: newSize.width, height: newSize.height).integral
        let imageRef = image.cgImage
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        // Set the quality level to use when rescaling
        context!.interpolationQuality = .high
        let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: newSize.height)
        
        context?.concatCTM(flipVertical)
        // Draw into the context; this scales the image
        context?.draw(in: newRect, image: imageRef!)
        
        let newImageRef = (context?.makeImage()!)! as CGImage
        let newImage = UIImage(cgImage: newImageRef)
        
        // Get the resized image from the context and a UIImage
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    private static func normalizedImage(_ image: UIImage) -> UIImage {
        if image.imageOrientation == .up {
            return image
        }
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: image.size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return normalizedImage!
    }
    
}
