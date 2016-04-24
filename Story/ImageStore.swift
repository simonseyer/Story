//
//  ImageStore.swift
//  Story
//
//  Created by COBI on 20.04.16.
//
//

import Foundation
import UIKit

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
            
            return Image(name: imageName, date: NSDate(), latitude: 0, longitude: 0)
        } catch let e as NSError {
            print(e)
        }
        
        return nil
    }
    
}