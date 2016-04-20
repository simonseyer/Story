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
    
    public static func loadImage(day: Day) -> UIImage? {
        let imageURL = NSURL(string: basePath)?.URLByAppendingPathComponent(day.image)
        if let url = imageURL {
            if let imageData = NSData(contentsOfURL: url) {
                return UIImage(data: imageData)
            }
        }
        return nil
    }
    
    public static func createDay(date: NSDate, text: String, image: UIImage) -> Day? {
        let imageData = UIImagePNGRepresentation(image)
        let imageName = NSUUID().UUIDString
        let imageURL = NSURL(string: basePath)?.URLByAppendingPathComponent(imageName)
        
        if let url = imageURL, data = imageData {
            do {
                try data.writeToURL(url, options: NSDataWritingOptions.init(rawValue: 0))
                
                // TODO: read location out of metadata
                
                return Day(date: date, image: imageName, text: text, latitude: 0, longitude: 0)
            } catch {
                
            }
        }
        return nil
    }
    
}