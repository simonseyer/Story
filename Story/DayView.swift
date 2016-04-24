//
//  DayView.swift
//  Story
//
//  Created by COBI on 20.04.16.
//
//

import UIKit

class DayView: UIView {

    let imageView = UIImageView()
    let textView = UILabel()
    let textBackgroundView = UIView()
    
    private let textViewXMargin = CGFloat(60)
    private let textViewYMargin = CGFloat(60)
    private let magicPageIndicatorHeight = CGFloat(37)
    
    init() {
        super.init(frame: CGRect.zero)
        setupContraints()
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupContraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        textBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(imageView)
        addSubview(textBackgroundView)
        addSubview(textView)
        
        imageView.leftAnchor.constraintEqualToAnchor(leftAnchor).active = true
        imageView.rightAnchor.constraintEqualToAnchor(rightAnchor).active = true
        imageView.topAnchor.constraintEqualToAnchor(topAnchor).active = true
        
        textBackgroundView.leftAnchor.constraintEqualToAnchor(leftAnchor).active = true
        textBackgroundView.rightAnchor.constraintEqualToAnchor(rightAnchor).active = true
        textBackgroundView.topAnchor.constraintEqualToAnchor(imageView.bottomAnchor).active = true
        textBackgroundView.bottomAnchor.constraintEqualToAnchor(bottomAnchor, constant: -TripView.mapViewHeight + magicPageIndicatorHeight).active = true
        
        textView.leftAnchor.constraintEqualToAnchor(leftAnchor, constant: textViewXMargin).active = true
        textView.rightAnchor.constraintEqualToAnchor(rightAnchor, constant: -textViewXMargin).active = true
        textView.topAnchor.constraintEqualToAnchor(textBackgroundView.topAnchor, constant: textViewYMargin).active = true
        textView.bottomAnchor.constraintEqualToAnchor(textBackgroundView.bottomAnchor, constant: -textViewYMargin).active = true
        textView.heightAnchor.constraintGreaterThanOrEqualToConstant(30).active = true
    }
    
    private func setupView() {
        clipsToBounds = true
        textBackgroundView.backgroundColor = UIColor(hexValue: ViewConstants.backgroundColorCode)
        
        imageView.contentMode = .ScaleAspectFill
        
        textView.numberOfLines = 0
        textView.font = ViewConstants.textFont()
        textView.textColor = UIColor(hexValue: ViewConstants.textColorCode)
        textView.textAlignment = .Justified
    }
}
