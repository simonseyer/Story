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
    
    private let textViewXMargin = CGFloat(60)
    private let textViewYMargin = CGFloat(60)
    
    private let backgroundColorCode = 0xFAF8F8
    private let textFontSize = CGFloat(21)
    private let textFontName = "Baskerville"
    
    init() {
        super.init(frame: CGRect.zero)
        setupContraints()
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupContraints() {
        addSubview(imageView)
        addSubview(textView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.leftAnchor.constraintEqualToAnchor(leftAnchor).active = true
        imageView.rightAnchor.constraintEqualToAnchor(rightAnchor).active = true
        imageView.topAnchor.constraintEqualToAnchor(topAnchor).active = true
        
        textView.leftAnchor.constraintEqualToAnchor(leftAnchor, constant: textViewXMargin).active = true
        textView.rightAnchor.constraintEqualToAnchor(rightAnchor, constant: -textViewXMargin).active = true
        textView.topAnchor.constraintEqualToAnchor(imageView.bottomAnchor, constant: textViewYMargin).active = true
        textView.bottomAnchor.constraintEqualToAnchor(bottomAnchor, constant: -textViewYMargin).active = true
        textView.heightAnchor.constraintGreaterThanOrEqualToConstant(30).active = true
    }
    
    private func setupView() {
        clipsToBounds = true
        backgroundColor = UIColor(hexValue: backgroundColorCode)
        
        imageView.contentMode = .ScaleAspectFill
        
        textView.numberOfLines = 0
        textView.font = UIFont(name: textFontName, size: textFontSize)
        textView.textAlignment = .Justified
    }
}
