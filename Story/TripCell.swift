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
    
    private var horizontalMotionEffect: UIInterpolatingMotionEffect?
    private var tripImageViewLeftConstraint: NSLayoutConstraint?
    private var tripImageViewRightConstraint: NSLayoutConstraint?
    
    let titleLeftMargin = CGFloat(30)
    
    var trip: Trip?
    
    var changeCommand: (Trip -> Void)?
    var doneCommand: (Void -> Void)?
    
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
                tripImageView.addMotionEffect(horizontalMotionEffect!)
                tripImageViewLeftConstraint?.constant = -ViewConstants.parallaxDelta
                tripImageViewRightConstraint?.constant = ViewConstants.parallaxDelta
            } else {
                tripImageView.removeMotionEffect(horizontalMotionEffect!)
                tripImageViewLeftConstraint?.constant = 0
                tripImageViewRightConstraint?.constant = 0
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
        
        
        tripImageViewLeftConstraint = tripImageView.leftAnchor.constraintEqualToAnchor(leftAnchor, constant: -ViewConstants.parallaxDelta)
        tripImageViewLeftConstraint?.active = true
        tripImageViewRightConstraint = tripImageView.rightAnchor.constraintEqualToAnchor(rightAnchor, constant: ViewConstants.parallaxDelta)
        tripImageViewRightConstraint?.active = true
        tripImageView.topAnchor.constraintEqualToAnchor(topAnchor, constant: 0).active = true
        tripImageView.bottomAnchor.constraintEqualToAnchor(bottomAnchor, constant: 0).active = true
        
        LayoutUtils.fullInSuperview(imageOverlayView, superView: tripImageView)
        
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
        //clipsToBounds = true
        layoutMargins = UIEdgeInsetsZero
        
        tripImageView.contentMode = .ScaleAspectFill
        tripImageView.clipsToBounds = true
        
        horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x",
                                                                type: .TiltAlongHorizontalAxis)
        horizontalMotionEffect!.minimumRelativeValue = -ViewConstants.parallaxDelta
        horizontalMotionEffect!.maximumRelativeValue = ViewConstants.parallaxDelta
        tripImageView.addMotionEffect(horizontalMotionEffect!)
        
        imageOverlayView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.15)
        
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
        let placeholder = NSAttributedString(string: "New Story", attributes: [NSForegroundColorAttributeName : UIColor.lightGrayColor().colorWithAlphaComponent(0.7)])
        tripTitleTextView.attributedPlaceholder = placeholder
        tripTitleTextView.returnKeyType = .Done
        
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        dispatch_async(dispatch_get_main_queue()) {[unowned self] in
            self.doneCommand?()
        }
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return true
        }
        let newString = (text as NSString).stringByReplacingCharactersInRange(range, withString: string)
        let ok = newString.characters.count <= 14
        if !ok {
            textField.text = (newString as NSString).substringToIndex(15)
            dispatch_async(dispatch_get_main_queue()) {
                self.tripTitleTextView.transform = CGAffineTransformMakeTranslation(6, 0)
                self.tripTitleBottomBorder.transform = CGAffineTransformMakeTranslation(6, 0)
                UIView.animateWithDuration(0.7, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 20, options: UIViewAnimationOptions(), animations: { () -> Void in
                    self.tripTitleTextView.transform = CGAffineTransformIdentity
                    self.tripTitleBottomBorder.transform = CGAffineTransformIdentity
                }, completion: nil)
            }
        }
        return ok
    }
}
