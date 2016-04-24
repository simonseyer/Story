//
//  NewTripCell.swift
//  Story
//
//  Created by COBI on 24.04.16.
//
//

import UIKit
import QuartzCore

class NewTripCell: UITableViewCell {

    let titleLabel = UILabel()
    let borderView = UIView()
    let border = DashedBorderShapeLayer()
    
    private let borderViewXMargin = CGFloat(20)
    private let borderViewYMargin = CGFloat(20)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupContraints()
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupContraints() {
        borderView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(borderView)
        borderView.layer.addSublayer(border)
        addSubview(titleLabel)
        
        borderView.leftAnchor.constraintEqualToAnchor(leftAnchor, constant: borderViewXMargin).active = true
        borderView.rightAnchor.constraintEqualToAnchor(rightAnchor, constant: -borderViewXMargin).active = true
        borderView.topAnchor.constraintEqualToAnchor(topAnchor, constant: borderViewYMargin).active = true
        borderView.bottomAnchor.constraintEqualToAnchor(bottomAnchor, constant: -borderViewYMargin).active = true
        
        titleLabel.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
        titleLabel.centerXAnchor.constraintEqualToAnchor(centerXAnchor).active = true
    }
    
    private func setupView() {
        clipsToBounds = true
       
        backgroundColor = UIColor(hexValue: ViewConstants.backgroundColorCode)
        
        titleLabel.numberOfLines = 1
        titleLabel.font = ViewConstants.textFont()
        titleLabel.textAlignment = .Center
        titleLabel.textColor = UIColor(hexValue: ViewConstants.lightTextColorCode)
        
        titleLabel.text = "Tell a New Story"
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        border.frame = borderView.bounds
    }
    
}

class DashedBorderShapeLayer : CAShapeLayer {
    
    override init() {
        super.init()
        
        strokeColor = UIColor(hexValue: ViewConstants.borderColorCode).CGColor
        fillColor = nil
        lineDashPattern = [6, 5]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var frame: CGRect {
        didSet {
            path = UIBezierPath(roundedRect: frame, cornerRadius: 8).CGPath
        }
    }
    
}
