//
//  LayoutUtils.swift
//  Story
//
//  Created by COBI on 25.04.16.
//
//

import UIKit

struct LayoutUtils {
    
    static func fullInSuperview(_ view: UIView, superView: UIView, margin: CGFloat = 0) {
        view.leftAnchor.constraint(equalTo: superView.leftAnchor, constant: margin).isActive = true
        view.rightAnchor.constraint(equalTo: superView.rightAnchor, constant: -margin).isActive = true
        view.topAnchor.constraint(equalTo: superView.topAnchor, constant: margin).isActive = true
        view.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: -margin).isActive = true
    }
    
}
