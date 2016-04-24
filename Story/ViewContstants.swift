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
    static let textColorCode = 0x363636
    static let lightTextColorCode = 0x979797
    static let borderColorCode = 0xC4C2C2
    static let textFontSize = CGFloat(21)
    static let textFontName = "Baskerville"
    static let boldTextFontName = "Baskerville-Semibold"
    
    static func textFont() -> UIFont? {
        return UIFont(name: textFontName, size: textFontSize)
    }
}