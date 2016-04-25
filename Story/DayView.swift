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
    let imageOverlayView = UIView()
    let imageSelectionView = UIView()
    let imageSelectionBorder = DashedBorderShapeLayer()
    
    let textBackgroundView = UIView()
    let textEditView = UIView()
    let textEditBorder = DashedBorderShapeLayer()
    let editTextView = UITextView()
    let textView = UILabel()
    
    var topLayoutGuide: UILayoutSupport? {
        didSet {
            if let topLayoutGuide = topLayoutGuide {
                imageSelectionView.topAnchor.constraintEqualToAnchor(topLayoutGuide.bottomAnchor, constant: editViewMargin).active = true
            }
        }
    }
    
    var keyboardConstraint: NSLayoutConstraint?
    private var tapGestureRecognizer: UITapGestureRecognizer?
    
    private let textViewXMargin = CGFloat(60)
    private let textViewYMargin = CGFloat(60)
    private let magicPageIndicatorHeight = CGFloat(37)
    private let textViewHeight = CGFloat(80)
    private let editViewMargin = CGFloat(20)
    private let editTextViewMargin = CGFloat(8)
    
    
    var text: String? {
        get {
            return textView.text
        }
        set {
            textView.text = newValue
            editTextView.text = newValue
            
        }
    }
    
    var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
        }
    }
    
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
        imageOverlayView.translatesAutoresizingMaskIntoConstraints = false
        imageSelectionView.translatesAutoresizingMaskIntoConstraints = false
        textBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        textEditView.translatesAutoresizingMaskIntoConstraints = false
        editTextView.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(imageView)
        addSubview(imageOverlayView)
        addSubview(imageSelectionView)
        imageSelectionView.layer.addSublayer(imageSelectionBorder)
        
        addSubview(textBackgroundView)
        addSubview(textEditView)
        textEditView.layer.addSublayer(textEditBorder)
        textEditView.addSubview(editTextView)
        addSubview(textView)
        
        imageView.leftAnchor.constraintEqualToAnchor(leftAnchor).active = true
        imageView.rightAnchor.constraintEqualToAnchor(rightAnchor).active = true
        imageView.topAnchor.constraintEqualToAnchor(topAnchor).active = true
        
        LayoutUtils.fullInSuperview(imageOverlayView, superView: imageView)
        
        imageSelectionView.leftAnchor.constraintEqualToAnchor(imageView.leftAnchor, constant: editViewMargin).active = true
        imageSelectionView.rightAnchor.constraintEqualToAnchor(imageView.rightAnchor, constant: -editViewMargin).active = true
        imageSelectionView.bottomAnchor.constraintEqualToAnchor(imageView.bottomAnchor, constant: -editViewMargin).active = true
        
        textBackgroundView.leftAnchor.constraintEqualToAnchor(leftAnchor).active = true
        textBackgroundView.rightAnchor.constraintEqualToAnchor(rightAnchor).active = true
        textBackgroundView.topAnchor.constraintEqualToAnchor(imageView.bottomAnchor).active = true
        textBackgroundView.bottomAnchor.constraintLessThanOrEqualToAnchor(bottomAnchor, constant: -TripView.mapViewHeight + magicPageIndicatorHeight).active = true
        keyboardConstraint = textBackgroundView.bottomAnchor.constraintLessThanOrEqualToAnchor(bottomAnchor)
        keyboardConstraint?.active = true
        
        LayoutUtils.fullInSuperview(textEditView, superView: textBackgroundView, margin: editViewMargin)
        
        LayoutUtils.fullInSuperview(editTextView, superView: textEditView, margin: editTextViewMargin)
        
        textView.leftAnchor.constraintEqualToAnchor(leftAnchor, constant: textViewXMargin).active = true
        textView.rightAnchor.constraintEqualToAnchor(rightAnchor, constant: -textViewXMargin).active = true
        textView.topAnchor.constraintEqualToAnchor(textBackgroundView.topAnchor, constant: textViewYMargin).active = true
        textView.bottomAnchor.constraintEqualToAnchor(textBackgroundView.bottomAnchor, constant: -textViewYMargin).active = true
        textView.heightAnchor.constraintGreaterThanOrEqualToConstant(textViewHeight).active = true
    }
    
    private func setupView() {
        clipsToBounds = true
        textBackgroundView.backgroundColor = UIColor(hexValue: ViewConstants.backgroundColorCode)
        
        imageView.contentMode = .ScaleAspectFill
        
        imageOverlayView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.4)
        imageOverlayView.alpha = 0
        imageSelectionView.alpha = 0
        
        textView.numberOfLines = 0
        textView.font = ViewConstants.textFont()
        textView.textColor = UIColor(hexValue: ViewConstants.textColorCode)
        textView.textAlignment = .Justified
        
        textEditView.alpha = 0
        
        editTextView.font = textView.font
        editTextView.textColor = textView.textColor
        editTextView.backgroundColor = UIColor.clearColor()
        editTextView.tintColor = textView.textColor
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageSelectionBorder.frame = imageSelectionView.bounds
        textEditBorder.frame = textEditView.bounds
    }
    
    func setEditing(editing: Bool, animated: Bool) {
        if animated {
            UIView.animateWithDuration(0.25) {[unowned self] in
                self.setEditing(editing)
            }
        } else {
            setEditing(editing)
        }
    }
    
    private func setEditing(editing: Bool) {
        imageOverlayView.alpha = editing ? 1 : 0
        imageSelectionView.alpha = editing ? 1 : 0
        textEditView.alpha = editing ? 1 : 0
        textView.alpha = editing ? 0 : 1
        if editing {
            if let tapGestureRecognizer = tapGestureRecognizer {
                addGestureRecognizer(tapGestureRecognizer)
            }
        } else {
            if let tapGestureRecognizer = tapGestureRecognizer {
                removeGestureRecognizer(tapGestureRecognizer)
            }
            dismissKeyboard()
        }
    }
    
    func dismissKeyboard() {
        editTextView.resignFirstResponder()
    }
}
