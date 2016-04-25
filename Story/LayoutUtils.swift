//
//  LayoutUtils.swift
//  Story
//
//  Created by COBI on 25.04.16.
//
//

import UIKit

struct LayoutUtils {
    
    static func fullInSuperview(view: UIView, superView: UIView, margin: CGFloat = 0) {
        view.leftAnchor.constraintEqualToAnchor(superView.leftAnchor, constant: margin).active = true
        view.rightAnchor.constraintEqualToAnchor(superView.rightAnchor, constant: -margin).active = true
        view.topAnchor.constraintEqualToAnchor(superView.topAnchor, constant: margin).active = true
        view.bottomAnchor.constraintEqualToAnchor(superView.bottomAnchor, constant: -margin).active = true
    }
    
}
