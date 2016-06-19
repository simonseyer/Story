//
//  DashedBorderShapeLayer.swift
//  Story
//
//  Created by COBI on 25.04.16.
//
//

import UIKit

class DashedBorderShapeLayer : CAShapeLayer {
    
    override init(layer: AnyObject) {
        super.init(layer: layer)
        setupLayer()
    }
    
    override init() {
        super.init()
        setupLayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    private func setupLayer() {
        strokeColor = UIColor(hexValue: ViewConstants.borderColorCode).cgColor
        fillColor = nil
        lineDashPattern = [6, 5]
    }
    
    override var frame: CGRect {
        didSet {
            path = UIBezierPath(roundedRect: frame, cornerRadius: 8).cgPath
        }
    }
    
}
