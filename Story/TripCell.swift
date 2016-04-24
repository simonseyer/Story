//
//  TripCell.swift
//  Story
//
//  Created by COBI on 24.04.16.
//
//

import UIKit

class TripCell: UITableViewCell, UITextFieldDelegate {
    
    let tripImageView = UIImageView()
    let tripTitleView = UILabel()
    let imageOverlayView = UIView()
    let tripTitleTextView = UITextField()
    let tripTitleBottomBorder = UIView()
    
    let titleLeftMargin = CGFloat(30)
    
    var trip: Trip?
    
    var changeCommand: (Trip -> Void)?
    
    var tripTitle: String? {
        get {
            return tripTitleView.text
        }
        set {
            tripTitleView.text = newValue
            tripTitleTextView.text = newValue
            
        }
    }
    
    var tripImage: UIImage? {
        get {
            return tripImageView.image
        }
        set {
            tripImageView.image = newValue
        }
    }
    
    var editMode: Bool = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if editMode != editing {
            if !self.editing {
                self.tripTitleTextView.resignFirstResponder()
            }
            self.imageOverlayView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(self.editing ? 0.4 : 0.1)
            self.tripTitleView.alpha = self.editing ? 0 : 1
            self.tripTitleTextView.alpha = self.editing ? 1 : 0
            self.tripTitleBottomBorder.alpha = self.editing ? 1 : 0
            editMode = editing
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
        tripTitleTextView.translatesAutoresizingMaskIntoConstraints = false
        tripTitleBottomBorder.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(tripImageView)
        addSubview(imageOverlayView)
        addSubview(tripTitleView)
        addSubview(tripTitleTextView)
        addSubview(tripTitleBottomBorder)
        
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
        tripTitleView.heightAnchor.constraintGreaterThanOrEqualToConstant(40).active = true
        
        tripTitleTextView.topAnchor.constraintEqualToAnchor(tripTitleView.topAnchor, constant: -4).active = true
        tripTitleTextView.heightAnchor.constraintEqualToAnchor(tripTitleView.heightAnchor).active = true
        tripTitleTextView.leftAnchor.constraintEqualToAnchor(tripTitleView.leftAnchor, constant: 20).active = true
        tripTitleTextView.rightAnchor.constraintEqualToAnchor(rightAnchor, constant: -titleLeftMargin).active = true
        
        tripTitleBottomBorder.topAnchor.constraintEqualToAnchor(tripTitleTextView.bottomAnchor, constant: 1).active = true
        tripTitleBottomBorder.leftAnchor.constraintEqualToAnchor(tripTitleTextView.leftAnchor).active = true
        tripTitleBottomBorder.rightAnchor.constraintEqualToAnchor(tripTitleTextView.rightAnchor).active = true
        tripTitleBottomBorder.heightAnchor.constraintEqualToConstant(2).active = true
    }
    
    private func setupView() {
        clipsToBounds = true
        layoutMargins = UIEdgeInsetsZero
        
        tripImageView.contentMode = .ScaleAspectFill
        tripImageView.clipsToBounds = true
        
        imageOverlayView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.05)
        
        tripTitleView.numberOfLines = 1
        tripTitleView.font = UIFont(name: ViewConstants.boldTextFontName, size: 35)
        tripTitleView.textAlignment = .Left
        tripTitleView.textColor = UIColor.whiteColor()
        tripTitleView.shadowColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
        tripTitleView.shadowOffset = CGSize(width: 2, height: 2)
        
        tripTitleTextView.font = UIFont(name: ViewConstants.boldTextFontName, size: 35)
        tripTitleTextView.textAlignment = tripTitleView.textAlignment
        tripTitleTextView.textColor = tripTitleView.textColor
        tripTitleTextView.alpha = 0
        tripTitleTextView.backgroundColor = UIColor.clearColor()
        tripTitleTextView.tintColor = UIColor.whiteColor()
        tripTitleTextView.delegate = self
        
        tripTitleBottomBorder.backgroundColor = UIColor.whiteColor()
        tripTitleBottomBorder.alpha = 0
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if let trip = trip, text = textField.text {
            var newTrip = trip
            newTrip.name = text
            changeCommand?(newTrip)
        }
    }
    
}
