//
//  ViewContstants.swift
//  Story
//
//  Created by COBI on 24.04.16.
//
//

import Foundation
import UIKit

struct ViewConstants {
    static let backgroundColorCode = 0xFAF8F8
    static let textFontSize = CGFloat(21)
    static let textFontName = "Baskerville"
    
    static func textFont() -> UIFont? {
        return UIFont(name: textFontName, size: textFontSize)
    }
}