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
    func didSelectSource(_ source: ImagePickerSource)
}

class ImagePickerView: UIStackView {

    var sourceViews = [UIButton]()
    
    weak var delegate: ImagePickerViewDelegate?
    
    var darkMode = false {
        didSet {
            for button in sourceViews {
                button.tintColor = darkMode ? UIColor(hexValue: ViewConstants.borderColorCode) : UIColor.white()
                button.setTitleColor(darkMode ? UIColor(hexValue: ViewConstants.lightTextColorCode) : UIColor.white(), for: UIControlState())
            }
        }
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        axis = .vertical
        distribution = .equalSpacing
        spacing = 20
        backgroundColor = UIColor.red()
    }
    
    func addSource(_ source: ImagePickerSource) {
        let button = SourceButton(source: source)
        
        button.titleLabel?.font = ViewConstants.textFont()
        button.setTitle(source.rawValue, for: UIControlState())
        button.setTitleColor(UIColor.white(), for: UIControlState())
        
        button.addTarget(self, action: #selector(didPressButton), for: .touchUpInside)
        
        sourceViews.append(button)
        
        addArrangedSubview(button)
    }
    
    func didPressButton(_ sender: UIButton) {
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
        super.init(frame: CGRect.zero)
        
        borderLayer.strokeColor = UIColor.white().cgColor
        borderLayer.fillColor = UIColor.clear().cgColor
        layer.addSublayer(borderLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private override func layoutSubviews() {
        super.layoutSubviews()
        
        borderLayer.frame = bounds
        borderLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 8).cgPath
    }
    
    private override func tintColorDidChange() {
        borderLayer.strokeColor = tintColor.cgColor
    }
}
