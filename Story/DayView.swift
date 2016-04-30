//
//  DayView.swift
//  Story
//
//  Created by COBI on 20.04.16.
//
//

import UIKit
import PhotosUI

class DayView: UIView, UITextViewDelegate {

    let imageView = UIImageView()
    let livePhotoView = PHLivePhotoView()
    let imageOverlayView = UIView()
    let imageSelectionView = UIView()
    let imagePickerView = ImagePickerView()
    let imageSelectionBorder = DashedBorderShapeLayer()
    let imageProcessingSpinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    
    let textBackgroundView = UIView()
    let textPlaceholderLabel = UILabel()
    let textEditContainerView = UIView()
    let textEditBorder = DashedBorderShapeLayer()
    let editTextView = UITextView()
    let characterCountLabel = UILabel()
    let textLabel = UILabel()
    
    var topLayoutGuide: UILayoutSupport?
    
    var keyboardConstraint: NSLayoutConstraint?
    var keyboardMode = false {
        didSet {
            updateViewVisibilities()
        }
    }
    private var tapGestureRecognizer: UITapGestureRecognizer?
    
    private let textViewXMargin = CGFloat(30)
    private let textViewYMargin = CGFloat(20)
    private let magicPageIndicatorHeight = CGFloat(37)
    private let textViewHeight = CGFloat(140)
    private let editViewMargin = CGFloat(20)
    private let magicTopMargin = CGFloat(66)
    private let editTextViewMargin = CGFloat(8)
    
    private var editing = false
    
    var text: String? {
        get {
            return textLabel.attributedText?.string
        }
        set {
            if let text = newValue {
                let string = NSAttributedString(string: text, attributes: [
                    NSFontAttributeName : textLabel.font,
                    NSForegroundColorAttributeName : textLabel.textColor
                ])
                textLabel.attributedText = string
            } else {
                textLabel.attributedText = nil
            }
            editTextView.text = newValue
            updateViewVisibilities(false)
            updateCharacterCountLabel()
        }
    }
    
    var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            updateViewVisibilities(false)
        }
    }
    
    var livePhoto: PHLivePhoto? {
        get {
            return livePhotoView.livePhoto
        }
        set {
            livePhotoView.livePhoto = newValue
        }
    }
    
    var didEndEditTextCommand: (String? -> Void)?
    
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
        livePhotoView.translatesAutoresizingMaskIntoConstraints = false
        imageOverlayView.translatesAutoresizingMaskIntoConstraints = false
        imageSelectionView.translatesAutoresizingMaskIntoConstraints = false
        textBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        textPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
        textEditContainerView.translatesAutoresizingMaskIntoConstraints = false
        editTextView.translatesAutoresizingMaskIntoConstraints = false
        characterCountLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        imagePickerView.translatesAutoresizingMaskIntoConstraints = false
        imageProcessingSpinner.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(imageView)
        addSubview(livePhotoView)
        addSubview(imageOverlayView)
        addSubview(imageSelectionView)
        imageSelectionView.layer.addSublayer(imageSelectionBorder)
        addSubview(imagePickerView)
        addSubview(imageProcessingSpinner)
        
        addSubview(textBackgroundView)
        addSubview(textPlaceholderLabel)
        addSubview(textEditContainerView)
        textEditContainerView.layer.addSublayer(textEditBorder)
        textEditContainerView.addSubview(editTextView)
        addSubview(characterCountLabel)
        addSubview(textLabel)
        
        imageView.leftAnchor.constraintEqualToAnchor(leftAnchor, constant: -ViewConstants.parallaxDelta).active = true
        imageView.rightAnchor.constraintEqualToAnchor(rightAnchor, constant: ViewConstants.parallaxDelta).active = true
        imageView.topAnchor.constraintEqualToAnchor(topAnchor).active = true
        let maxHeightConstraint = imageView.heightAnchor.constraintEqualToConstant(1000)
        maxHeightConstraint.priority = UILayoutPriorityDefaultLow
        maxHeightConstraint.active = true
        
        LayoutUtils.fullInSuperview(livePhotoView, superView: imageView)
        
        LayoutUtils.fullInSuperview(imageOverlayView, superView: imageView)
        
        imageSelectionView.leftAnchor.constraintEqualToAnchor(leftAnchor, constant: editViewMargin).active = true
        imageSelectionView.rightAnchor.constraintEqualToAnchor(rightAnchor, constant: -editViewMargin).active = true
        imageSelectionView.topAnchor.constraintEqualToAnchor(topAnchor, constant: editViewMargin + magicTopMargin).active = true
        imageSelectionView.bottomAnchor.constraintEqualToAnchor(imageView.bottomAnchor, constant: -editViewMargin).active = true
        
        imagePickerView.leftAnchor.constraintEqualToAnchor(imageSelectionView.leftAnchor, constant: 40).active = true
        imagePickerView.rightAnchor.constraintEqualToAnchor(imageSelectionView.rightAnchor, constant: -40).active = true
        imagePickerView.centerYAnchor.constraintEqualToAnchor(imageSelectionView.centerYAnchor).active = true
        
        imageProcessingSpinner.centerXAnchor.constraintEqualToAnchor(imageSelectionView.centerXAnchor).active = true
        imageProcessingSpinner.centerYAnchor.constraintEqualToAnchor(imageSelectionView.centerYAnchor).active = true
        
        textBackgroundView.leftAnchor.constraintEqualToAnchor(leftAnchor).active = true
        textBackgroundView.rightAnchor.constraintEqualToAnchor(rightAnchor).active = true
        textBackgroundView.topAnchor.constraintEqualToAnchor(imageView.bottomAnchor).active = true
        textBackgroundView.bottomAnchor.constraintLessThanOrEqualToAnchor(bottomAnchor, constant: -TripView.mapViewHeight + magicPageIndicatorHeight).active = true
        keyboardConstraint = textBackgroundView.bottomAnchor.constraintLessThanOrEqualToAnchor(bottomAnchor)
        keyboardConstraint?.active = true
        
        textPlaceholderLabel.leftAnchor.constraintEqualToAnchor(editTextView.leftAnchor, constant: 6).active = true
        textPlaceholderLabel.rightAnchor.constraintEqualToAnchor(editTextView.rightAnchor, constant: -6).active = true
        textPlaceholderLabel.topAnchor.constraintEqualToAnchor(editTextView.topAnchor, constant: 8).active = true
        
        LayoutUtils.fullInSuperview(textEditContainerView, superView: textBackgroundView, margin: editViewMargin)
        
        LayoutUtils.fullInSuperview(editTextView, superView: textEditContainerView, margin: editTextViewMargin)
        
        characterCountLabel.rightAnchor.constraintEqualToAnchor(textLabel.rightAnchor).active = true
        characterCountLabel.topAnchor.constraintEqualToAnchor(textLabel.bottomAnchor, constant: 8).active = true
        
        textLabel.leftAnchor.constraintEqualToAnchor(leftAnchor, constant: textViewXMargin).active = true
        textLabel.rightAnchor.constraintEqualToAnchor(rightAnchor, constant: -textViewXMargin).active = true
        textLabel.topAnchor.constraintEqualToAnchor(textBackgroundView.topAnchor, constant: textViewYMargin).active = true
        textLabel.bottomAnchor.constraintEqualToAnchor(textBackgroundView.bottomAnchor, constant: -textViewYMargin).active = true
        textLabel.heightAnchor.constraintEqualToConstant(textViewHeight).active = true
    }
    
    private func setupView() {
        clipsToBounds = true
        textBackgroundView.backgroundColor = UIColor(hexValue: ViewConstants.backgroundColorCode)
        
        imageView.contentMode = .ScaleAspectFill
        
        livePhotoView.contentMode = .ScaleAspectFill
        livePhotoView.userInteractionEnabled = false
        
        let horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x",
                                                                 type: .TiltAlongHorizontalAxis)
        horizontalMotionEffect.minimumRelativeValue = -ViewConstants.parallaxDelta
        horizontalMotionEffect.maximumRelativeValue = ViewConstants.parallaxDelta
        imageView.addMotionEffect(horizontalMotionEffect)
        
        imageOverlayView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.55)

        imageOverlayView.alpha = 0
        imageSelectionView.alpha = 0
        
        imageProcessingSpinner.hidesWhenStopped = true
        
        textPlaceholderLabel.font = ViewConstants.textFont()
        textPlaceholderLabel.textColor = UIColor(hexValue: ViewConstants.textColorCode)
        textPlaceholderLabel.alpha = 0.5
        textPlaceholderLabel.numberOfLines = 0
        textPlaceholderLabel.text = "What happend in this moment?"
        
        textLabel.numberOfLines = 0
        textLabel.font = ViewConstants.textFont()
        textLabel.textColor = UIColor(hexValue: ViewConstants.textColorCode)
        textLabel.textAlignment = .Justified
        
        textEditContainerView.alpha = 0
        
        editTextView.font = textLabel.font
        editTextView.textColor = textLabel.textColor
        editTextView.backgroundColor = UIColor.clearColor()
        editTextView.tintColor = textLabel.textColor
        editTextView.delegate = self
        
        characterCountLabel.font = UIFont(name: ViewConstants.textFontName, size: 14)
        characterCountLabel.textColor = UIColor(hexValue: ViewConstants.lightTextColorCode)
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        updateViewVisibilities(false)
        updateCharacterCountLabel()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageSelectionBorder.frame = imageSelectionView.bounds
        textEditBorder.frame = textEditContainerView.bounds
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
    
    func setProcessing(processing: Bool) {
        if processing {
            imageProcessingSpinner.startAnimating()
        } else {
            imageProcessingSpinner.stopAnimating()
        }
        updateViewVisibilities()
    }
    
    private func setEditing(editing: Bool) {
        self.editing = editing
        
        updateViewVisibilities()
        
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
    
    private func updateViewVisibilities(animated: Bool = true) {
        textPlaceholderLabel.alpha = (editing && editTextView.text.characters.count == 0) ? 0.5 : 0.0
        UIView.animateWithDuration(animated ? 0.3 : 0.0) { [unowned self] in
            self._updateViewVisibilities()
        }
    }
    
    private func _updateViewVisibilities() {
        imageOverlayView.alpha = editing && imageView.image != nil ? 1 : 0
        imageSelectionView.alpha = (editing || imageView.image == nil) && !keyboardMode ? 1 : 0
        textEditContainerView.alpha = editing || textLabel.attributedText == nil ? 1 : 0
        editTextView.alpha = editing ? 1 : 0
        textLabel.alpha = editing ? 0 : 1
        imagePickerView.alpha = editing && !keyboardMode && !imageProcessingSpinner.isAnimating() ? 1 : 0
        imagePickerView.darkMode = imageView.image == nil
        characterCountLabel.alpha = editing && keyboardMode ? 1.0 : 0.0
    }
    
    
    func dismissKeyboard() {
        editTextView.resignFirstResponder()
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        didEndEditTextCommand?(textView.text)
    }

    func textViewDidChange(textView: UITextView) {
        self.updateViewVisibilities()
        updateCharacterCountLabel()
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        guard let oldText = textView.text else {
            return true
        }
        let newString = (oldText as NSString).stringByReplacingCharactersInRange(range, withString: text)
        let ok = newString.characters.count <= 140
        if !ok {
            textView.text = (newString as NSString).substringToIndex(141)

            dispatch_async(dispatch_get_main_queue()) {
                self.characterCountLabel.transform = CGAffineTransformMakeTranslation(6, 0)
                UIView.animateWithDuration(0.7, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 20, options: UIViewAnimationOptions(), animations: { () -> Void in
                    self.characterCountLabel.transform = CGAffineTransformIdentity
                }, completion: nil)
            }
        }
        return ok
    }
    
    private func updateCharacterCountLabel() {
        characterCountLabel.text = "\(min(editTextView.text?.characters.count ?? 0, 140)) / 140"
    }
    
}
