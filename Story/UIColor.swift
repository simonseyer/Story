//
//  UIColor.swift
//  Story
//
//  Created by COBI on 20.04.16.
//
//

import UIKit

public extension UIColor {
    
    convenience init(hexValue: Int) {
        self.init(hexValue:hexValue, alpha:1.0)
    }
    
    convenience init(hexValue: Int, alpha: CGFloat) {
        let r = CGFloat((hexValue & 0xFF0000) >> 16)/255
        let g = CGFloat((hexValue & 0xFF00) >> 8)/255
        let b = CGFloat(hexValue & 0xFF)/255
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
    
    func colorWithBrightnessDelta(brightnessDelta: CGFloat) -> UIColor {
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        
        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        brightness = max(0, brightness - brightnessDelta)
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
}