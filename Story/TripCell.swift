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
    let imageOverlayView = UIView()
    
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
        imageOverlayView.translatesAutoresizingMaskIntoConstraints = false
        tripTitleView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(tripImageView)
        addSubview(imageOverlayView)
        addSubview(tripTitleView)
        
        tripImageView.leftAnchor.constraintEqualToAnchor(leftAnchor).active = true
        tripImageView.bottomAnchor.constraintEqualToAnchor(bottomAnchor).active = true
        tripImageView.rightAnchor.constraintEqualToAnchor(rightAnchor).active = true
        tripImageView.topAnchor.constraintEqualToAnchor(topAnchor).active = true
        
        imageOverlayView.leftAnchor.constraintEqualToAnchor(leftAnchor).active = true
        imageOverlayView.bottomAnchor.constraintEqualToAnchor(bottomAnchor).active = true
        imageOverlayView.rightAnchor.constraintEqualToAnchor(rightAnchor).active = true
        imageOverlayView.topAnchor.constraintEqualToAnchor(topAnchor).active = true
        
        tripTitleView.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
        tripTitleView.leftAnchor.constraintEqualToAnchor(leftAnchor, constant: titleLeftMargin).active = true
    }
    
    private func setupView() {
        clipsToBounds = true
        
        tripImageView.contentMode = .ScaleAspectFill
        
        imageOverlayView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.05)
        
        tripTitleView.numberOfLines = 1
        tripTitleView.font = UIFont(name: ViewConstants.boldTextFontName, size: 35)
        tripTitleView.textAlignment = .Left
        tripTitleView.textColor = UIColor.whiteColor()
        tripTitleView.shadowColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
        tripTitleView.shadowOffset = CGSize(width: 2, height: 2)
        
        
    }
    
    
    
}
