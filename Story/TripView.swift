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
    
    private let mapViewHeight = CGFloat(120)
    
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
        addSubview(mapView)
        
        dayContainerView.translatesAutoresizingMaskIntoConstraints = false
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        dayContainerView.leftAnchor.constraintEqualToAnchor(leftAnchor).active = true
        dayContainerView.rightAnchor.constraintEqualToAnchor(rightAnchor).active = true
        dayContainerView.topAnchor.constraintEqualToAnchor(topAnchor).active = true
        
        mapView.heightAnchor.constraintEqualToConstant(mapViewHeight).active = true
        mapView.topAnchor.constraintEqualToAnchor(dayContainerView.bottomAnchor).active = true
        mapView.leftAnchor.constraintEqualToAnchor(leftAnchor).active = true
        mapView.rightAnchor.constraintEqualToAnchor(rightAnchor).active = true
        mapView.bottomAnchor.constraintEqualToAnchor(bottomAnchor).active = true
    }
    
    private func setupView() {
        backgroundColor = UIColor(hexValue: 0xFAF8F8)
    }
    
    func setDayView(dayView: UIView) {
        dayView.translatesAutoresizingMaskIntoConstraints = false
        
        dayContainerView.addSubview(dayView)
        
        dayView.leftAnchor.constraintEqualToAnchor(dayContainerView.leftAnchor).active = true
        dayView.bottomAnchor.constraintEqualToAnchor(dayContainerView.bottomAnchor).active = true
        dayView.rightAnchor.constraintEqualToAnchor(dayContainerView.rightAnchor).active = true
        dayView.topAnchor.constraintEqualToAnchor(dayContainerView.topAnchor).active = true
    }
}
