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
    
    var changeCommand: ((Trip) -> Void)?
    var doneCommand: ((Void) -> Void)?
    
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
        
        if editMode != isEditing {
            if !self.isEditing {
                self.tripTitleTextView.resignFirstResponder()
                tripImageView.addMotionEffect(horizontalMotionEffect!)
                tripImageViewLeftConstraint?.constant = -ViewConstants.parallaxDelta
                tripImageViewRightConstraint?.constant = ViewConstants.parallaxDelta
            } else {
                tripImageView.removeMotionEffect(horizontalMotionEffect!)
                tripImageViewLeftConstraint?.constant = 0
                tripImageViewRightConstraint?.constant = 0
            }
            self.imageOverlayView.backgroundColor = UIColor.black().withAlphaComponent(self.isEditing ? 0.4 : 0.1)
            self.tripTitleView.alpha = self.isEditing ? 0 : 1
            self.tripTitleTextView.alpha = self.isEditing ? 1 : 0
            self.tripTitleBottomBorder.alpha = self.isEditing ? 1 : 0
            editMode = isEditing
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
        
        
        tripImageViewLeftConstraint = tripImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: -ViewConstants.parallaxDelta)
        tripImageViewLeftConstraint?.isActive = true
        tripImageViewRightConstraint = tripImageView.rightAnchor.constraint(equalTo: rightAnchor, constant: ViewConstants.parallaxDelta)
        tripImageViewRightConstraint?.isActive = true
        tripImageView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        tripImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        
        LayoutUtils.fullInSuperview(imageOverlayView, superView: tripImageView)
        
        tripTitleView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        tripTitleView.leftAnchor.constraint(equalTo: leftAnchor, constant: titleLeftMargin).isActive = true
        tripTitleView.heightAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
        
        tripTitleTextView.topAnchor.constraint(equalTo: tripTitleView.topAnchor, constant: -4).isActive = true
        tripTitleTextView.heightAnchor.constraint(equalTo: tripTitleView.heightAnchor).isActive = true
        tripTitleTextView.leftAnchor.constraint(equalTo: tripTitleView.leftAnchor, constant: 20).isActive = true
        tripTitleTextView.rightAnchor.constraint(equalTo: rightAnchor, constant: -titleLeftMargin).isActive = true
        
        tripTitleBottomBorder.topAnchor.constraint(equalTo: tripTitleTextView.bottomAnchor, constant: 1).isActive = true
        tripTitleBottomBorder.leftAnchor.constraint(equalTo: tripTitleTextView.leftAnchor).isActive = true
        tripTitleBottomBorder.rightAnchor.constraint(equalTo: tripTitleTextView.rightAnchor).isActive = true
        tripTitleBottomBorder.heightAnchor.constraint(equalToConstant: 2).isActive = true
    }
    
    private func setupView() {
        //clipsToBounds = true
        layoutMargins = UIEdgeInsetsZero
        
        tripImageView.contentMode = .scaleAspectFill
        tripImageView.clipsToBounds = true
        
        horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x",
                                                                type: .tiltAlongHorizontalAxis)
        horizontalMotionEffect!.minimumRelativeValue = -ViewConstants.parallaxDelta
        horizontalMotionEffect!.maximumRelativeValue = ViewConstants.parallaxDelta
        tripImageView.addMotionEffect(horizontalMotionEffect!)
        
        imageOverlayView.backgroundColor = UIColor.black().withAlphaComponent(0.15)
        
        tripTitleView.numberOfLines = 1
        tripTitleView.font = UIFont(name: ViewConstants.boldTextFontName, size: 35)
        tripTitleView.textAlignment = .left
        tripTitleView.textColor = UIColor.white()
        tripTitleView.shadowColor = UIColor.black().withAlphaComponent(0.3)
        tripTitleView.shadowOffset = CGSize(width: 2, height: 2)
        
        tripTitleTextView.font = UIFont(name: ViewConstants.boldTextFontName, size: 35)
        tripTitleTextView.textAlignment = tripTitleView.textAlignment
        tripTitleTextView.textColor = tripTitleView.textColor
        tripTitleTextView.alpha = 0
        tripTitleTextView.backgroundColor = UIColor.clear()
        tripTitleTextView.tintColor = UIColor.white()
        tripTitleTextView.delegate = self
        let placeholder = AttributedString(string: "New Story", attributes: [NSForegroundColorAttributeName : UIColor.lightGray().withAlphaComponent(0.7)])
        tripTitleTextView.attributedPlaceholder = placeholder
        tripTitleTextView.returnKeyType = .done
        
        tripTitleBottomBorder.backgroundColor = UIColor.white()
        tripTitleBottomBorder.alpha = 0
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let trip = trip, text = textField.text {
            var newTrip = trip
            newTrip.name = text
            changeCommand?(newTrip)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        DispatchQueue.main.async {[unowned self] in
            self.doneCommand?()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return true
        }
        let newString = (text as NSString).replacingCharacters(in: range, with: string)
        let ok = newString.characters.count <= 14
        if !ok {
            textField.text = (newString as NSString).substring(to: 15)
            DispatchQueue.main.async {
                self.tripTitleTextView.transform = CGAffineTransform(translationX: 6, y: 0)
                self.tripTitleBottomBorder.transform = CGAffineTransform(translationX: 6, y: 0)
                UIView.animate(withDuration: 0.7, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 20, options: UIViewAnimationOptions(), animations: { () -> Void in
                    self.tripTitleTextView.transform = CGAffineTransform.identity
                    self.tripTitleBottomBorder.transform = CGAffineTransform.identity
                }, completion: nil)
            }
        }
        return ok
    }
}
