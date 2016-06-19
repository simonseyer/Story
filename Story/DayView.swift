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
    let imageProcessingSpinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
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
                let paragrahStyle = NSMutableParagraphStyle()
                paragrahStyle.alignment = .justified
                paragrahStyle.lineSpacing = 1.1
                
                let string = AttributedString(string: text, attributes: [
                    NSFontAttributeName : textLabel.font,
                    NSForegroundColorAttributeName : textLabel.textColor,
                    NSParagraphStyleAttributeName : paragrahStyle,
                    NSBaselineOffsetAttributeName : 0
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
    
    var didEndEditTextCommand: ((String?) -> Void)?
    
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
        
        imageView.leftAnchor.constraint(equalTo: leftAnchor, constant: -ViewConstants.parallaxDelta).isActive = true
        imageView.rightAnchor.constraint(equalTo: rightAnchor, constant: ViewConstants.parallaxDelta).isActive = true
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        let maxHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: 1000)
        maxHeightConstraint.priority = UILayoutPriorityDefaultLow
        maxHeightConstraint.isActive = true
        
        LayoutUtils.fullInSuperview(livePhotoView, superView: imageView)
        
        LayoutUtils.fullInSuperview(imageOverlayView, superView: imageView)
        
        imageSelectionView.leftAnchor.constraint(equalTo: leftAnchor, constant: editViewMargin).isActive = true
        imageSelectionView.rightAnchor.constraint(equalTo: rightAnchor, constant: -editViewMargin).isActive = true
        imageSelectionView.topAnchor.constraint(equalTo: topAnchor, constant: editViewMargin + magicTopMargin).isActive = true
        imageSelectionView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -editViewMargin).isActive = true
        
        imagePickerView.leftAnchor.constraint(equalTo: imageSelectionView.leftAnchor, constant: 40).isActive = true
        imagePickerView.rightAnchor.constraint(equalTo: imageSelectionView.rightAnchor, constant: -40).isActive = true
        imagePickerView.centerYAnchor.constraint(equalTo: imageSelectionView.centerYAnchor).isActive = true
        
        imageProcessingSpinner.centerXAnchor.constraint(equalTo: imageSelectionView.centerXAnchor).isActive = true
        imageProcessingSpinner.centerYAnchor.constraint(equalTo: imageSelectionView.centerYAnchor).isActive = true
        
        textBackgroundView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        textBackgroundView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        textBackgroundView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -1).isActive = true
        textBackgroundView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -TripView.mapViewHeight + magicPageIndicatorHeight).isActive = true
        keyboardConstraint = textBackgroundView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
        keyboardConstraint?.isActive = true
        
        textPlaceholderLabel.leftAnchor.constraint(equalTo: editTextView.leftAnchor, constant: 6).isActive = true
        textPlaceholderLabel.rightAnchor.constraint(equalTo: editTextView.rightAnchor, constant: -6).isActive = true
        textPlaceholderLabel.topAnchor.constraint(equalTo: editTextView.topAnchor, constant: 8).isActive = true
        
        LayoutUtils.fullInSuperview(textEditContainerView, superView: textBackgroundView, margin: editViewMargin)
        
        LayoutUtils.fullInSuperview(editTextView, superView: textEditContainerView, margin: editTextViewMargin)
        
        characterCountLabel.rightAnchor.constraint(equalTo: textLabel.rightAnchor).isActive = true
        characterCountLabel.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 8).isActive = true
        
        textLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: textViewXMargin).isActive = true
        textLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -textViewXMargin).isActive = true
        textLabel.topAnchor.constraint(equalTo: textBackgroundView.topAnchor, constant: textViewYMargin).isActive = true
        textLabel.bottomAnchor.constraint(equalTo: textBackgroundView.bottomAnchor, constant: -textViewYMargin).isActive = true
        textLabel.heightAnchor.constraint(equalToConstant: textViewHeight).isActive = true
    }
    
    private func setupView() {
        clipsToBounds = true
        textBackgroundView.backgroundColor = UIColor(hexValue: ViewConstants.backgroundColorCode)
        
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        livePhotoView.contentMode = .scaleAspectFill
        livePhotoView.isUserInteractionEnabled = false
        
        let horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x",
                                                                 type: .tiltAlongHorizontalAxis)
        horizontalMotionEffect.minimumRelativeValue = -ViewConstants.parallaxDelta
        horizontalMotionEffect.maximumRelativeValue = ViewConstants.parallaxDelta
        imageView.addMotionEffect(horizontalMotionEffect)
        
        imageOverlayView.backgroundColor = UIColor.black().withAlphaComponent(0.55)

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
        textLabel.textAlignment = .justified
        
        textEditContainerView.alpha = 0
        
        editTextView.font = textLabel.font
        editTextView.textColor = textLabel.textColor
        editTextView.backgroundColor = UIColor.clear()
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
    
    func setEditing(_ editing: Bool, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.25) {[unowned self] in
                self.setEditing(editing)
            }
        } else {
            setEditing(editing)
        }
    }
    
    func setProcessing(_ processing: Bool) {
        if processing {
            imageProcessingSpinner.startAnimating()
        } else {
            imageProcessingSpinner.stopAnimating()
        }
        updateViewVisibilities()
    }
    
    private func setEditing(_ editing: Bool) {
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
    
    private func updateViewVisibilities(_ animated: Bool = true) {
        textPlaceholderLabel.alpha = (editing && editTextView.text.characters.count == 0) ? 0.5 : 0.0
        UIView.animate(withDuration: animated ? 0.3 : 0.0) { [unowned self] in
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
    
    func textViewDidEndEditing(_ textView: UITextView) {
        didEndEditTextCommand?(textView.text)
    }

    func textViewDidChange(_ textView: UITextView) {
        self.updateViewVisibilities()
        updateCharacterCountLabel()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let oldText = textView.text else {
            return true
        }
        let newString = (oldText as NSString).replacingCharacters(in: range, with: text)
        let ok = newString.characters.count <= 140
        if !ok {
            textView.text = (newString as NSString).substring(to: 141)

            DispatchQueue.main.async {
                self.characterCountLabel.transform = CGAffineTransform(translationX: 6, y: 0)
                UIView.animate(withDuration: 0.7, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 20, options: UIViewAnimationOptions(), animations: { () -> Void in
                    self.characterCountLabel.transform = CGAffineTransform.identity
                }, completion: nil)
            }
        }
        return ok
    }
    
    private func updateCharacterCountLabel() {
        characterCountLabel.text = "\(min(editTextView.text?.characters.count ?? 0, 140)) / 140"
    }
    
}
