//
//  ImagePickerView.swift
//  Story
//
//  Created by COBI on 26.04.16.
//
//

import UIKit

enum ImagePickerSource: String {
    case Camera = "Camera"
    case PhotoLibrary = "Photo Library"
    case SavedPhotos = "Recent Photos"
}

protocol ImagePickerViewDelegate: class {
    func didSelectSource(source: ImagePickerSource)
}

class ImagePickerView: UIStackView {

    var sourceViews = [UIButton]()
    
    weak var delegate: ImagePickerViewDelegate?
    
    var darkMode = false {
        didSet {
            for button in sourceViews {
                button.tintColor = darkMode ? UIColor(hexValue: ViewConstants.borderColorCode) : UIColor.whiteColor()
                button.setTitleColor(darkMode ? UIColor(hexValue: ViewConstants.lightTextColorCode) : UIColor.whiteColor(), forState: .Normal)
            }
        }
    }
    
    init() {
        super.init(frame: CGRectZero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        axis = .Vertical
        distribution = .EqualSpacing
        spacing = 20
        backgroundColor = UIColor.redColor()
    }
    
    func addSource(source: ImagePickerSource) {
        let button = SourceButton(source: source)
        
        button.titleLabel?.font = ViewConstants.textFont()
        button.setTitle(source.rawValue, forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        
        button.addTarget(self, action: #selector(didPressButton), forControlEvents: .TouchUpInside)
        
        sourceViews.append(button)
        
        addArrangedSubview(button)
    }
    
    func didPressButton(sender: UIButton) {
        if let button = sender as? SourceButton {
            delegate?.didSelectSource(button.source)
        }
    }
    
    
    
    override func tintColorDidChange() {
        
    }
}

private class SourceButton: UIButton {
    
    let source: ImagePickerSource
    let borderLayer = CAShapeLayer()
    
    init(source: ImagePickerSource) {
        self.source = source
        super.init(frame: CGRectZero)
        
        borderLayer.strokeColor = UIColor.whiteColor().CGColor
        borderLayer.fillColor = UIColor.clearColor().CGColor
        layer.addSublayer(borderLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private override func layoutSubviews() {
        super.layoutSubviews()
        
        borderLayer.frame = bounds
        borderLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 8).CGPath
    }
    
    private override func tintColorDidChange() {
        borderLayer.strokeColor = tintColor.CGColor
    }
}