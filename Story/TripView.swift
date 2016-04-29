//
//  TripView.swift
//  Story
//
//  Created by COBI on 20.04.16.
//
//

import UIKit
import MapKit

class TripView: UIView {

    let dayContainerView = UIView()
    let mapView = MKMapView()
    let deleteButton = UIButton()
    
    static let mapViewHeight = CGFloat(120)
    
    init() {
        super.init(frame: CGRect.zero)
        setupContraints()
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupContraints() {
        addSubview(dayContainerView)
        addSubview(deleteButton)
        addSubview(mapView)
        
        
        dayContainerView.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        LayoutUtils.fullInSuperview(dayContainerView, superView: self)
        
        mapView.heightAnchor.constraintEqualToConstant(TripView.mapViewHeight).active = true
        mapView.leftAnchor.constraintEqualToAnchor(leftAnchor).active = true
        mapView.rightAnchor.constraintEqualToAnchor(rightAnchor).active = true
        mapView.bottomAnchor.constraintEqualToAnchor(bottomAnchor).active = true
        
        deleteButton.centerXAnchor.constraintEqualToAnchor(mapView.centerXAnchor).active = true
        deleteButton.centerYAnchor.constraintEqualToAnchor(mapView.centerYAnchor).active = true
    }
    
    private func setupView() {
        backgroundColor = UIColor(hexValue: ViewConstants.backgroundColorCode)
        
        mapView.zoomEnabled = false
        mapView.scrollEnabled = false
        mapView.rotateEnabled = false
        mapView.pitchEnabled = false
       
        mapView.alpha = 0.7
        
        deleteButton.titleLabel?.font = ViewConstants.textFont()
        deleteButton.setTitleColor(UIColor(hexValue: ViewConstants.tintTextColorCode), forState: .Normal)
        deleteButton.setTitle("Delete Moment", forState: .Normal)
        deleteButton.alpha = 0
    }
    
    func setDayView(dayView: UIView) {
        dayView.translatesAutoresizingMaskIntoConstraints = false
        
        dayContainerView.addSubview(dayView)
        LayoutUtils.fullInSuperview(dayView, superView: dayContainerView)
    }
    
    
}
