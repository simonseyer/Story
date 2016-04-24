//
//  TripCell.swift
//  Story
//
//  Created by COBI on 24.04.16.
//
//

import UIKit

class TripCell: UITableViewCell {

    let tripImageView = UIImageView()
    let tripTitleView = UILabel()
    let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.ExtraLight))
    
    let titleLeftMargin = CGFloat(40)
    
    var tripTitle: String? {
        get {
            return self.tripTitleView.text
        }
        set {
            self.tripTitleView.text = newValue
        }
    }
    
    var tripImage: UIImage? {
        get {
            return self.tripImageView.image
        }
        set {
            self.tripImageView.image = newValue
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupContraints()
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupContraints() {
        tripImageView.translatesAutoresizingMaskIntoConstraints = false
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        tripTitleView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(tripImageView)
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            addSubview(blurEffectView)
        }
        addSubview(tripTitleView)
        
        tripImageView.leftAnchor.constraintEqualToAnchor(leftAnchor).active = true
        tripImageView.bottomAnchor.constraintEqualToAnchor(bottomAnchor).active = true
        tripImageView.rightAnchor.constraintEqualToAnchor(rightAnchor).active = true
        tripImageView.topAnchor.constraintEqualToAnchor(topAnchor).active = true
        
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            blurEffectView.leftAnchor.constraintEqualToAnchor(leftAnchor).active = true
            blurEffectView.bottomAnchor.constraintEqualToAnchor(bottomAnchor).active = true
            blurEffectView.rightAnchor.constraintEqualToAnchor(rightAnchor).active = true
            blurEffectView.topAnchor.constraintEqualToAnchor(topAnchor).active = true
        }
        
        tripTitleView.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
        tripTitleView.leftAnchor.constraintEqualToAnchor(leftAnchor, constant: titleLeftMargin).active = true
    }
    
    private func setupView() {
        clipsToBounds = true
        
        tripImageView.contentMode = .ScaleAspectFill
        
        tripTitleView.numberOfLines = 1
        tripTitleView.font = ViewConstants.textFont()
        tripTitleView.textAlignment = .Left
    }
    
    
    
}
