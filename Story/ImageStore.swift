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
    
    private static let basePath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    
    public static func loadImage(image: Image) -> UIImage? {
        let imageURL = NSURL(string: basePath)?.URLByAppendingPathComponent(image.name)
        if let url = imageURL {
            do {
                return UIImage(data: try NSData(contentsOfFile: url.absoluteString, options: NSDataReadingOptions()))
            } catch let e as NSError {
                print("Error: \(e)")
            }
        }
        return nil
    }
    
    public static func storeImage(image: UIImage) -> Image? {
        let imageData = UIImagePNGRepresentation(image)
        let imageName = "\(NSUUID().UUIDString).png"
        let imageURL = NSURL(string: basePath)?.URLByAppendingPathComponent(imageName)
        
        if let url = imageURL, data = imageData where data.writeToFile(url.absoluteString, atomically: false) {
            // TODO: read location out of metadata
            
            return Image(name: imageName, latitude: 0, longitude: 0)
        }
        return nil
    }
    
}