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
        
        mapView.heightAnchor.constraint(equalToConstant: TripView.mapViewHeight).isActive = true
        mapView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        mapView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        deleteButton.centerXAnchor.constraint(equalTo: mapView.centerXAnchor).isActive = true
        deleteButton.centerYAnchor.constraint(equalTo: mapView.centerYAnchor).isActive = true
    }
    
    private func setupView() {
        backgroundColor = UIColor(hexValue: ViewConstants.backgroundColorCode)
        
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false
       
        mapView.alpha = 0.7
        
        deleteButton.titleLabel?.font = ViewConstants.textFont()
        deleteButton.setTitleColor(UIColor(hexValue: ViewConstants.tintTextColorCode), for: UIControlState())
        deleteButton.setTitle("Delete Moment", for: UIControlState())
        deleteButton.alpha = 0
    }
    
    func setDayView(_ dayView: UIView) {
        dayView.translatesAutoresizingMaskIntoConstraints = false
        
        dayContainerView.addSubview(dayView)
        LayoutUtils.fullInSuperview(dayView, superView: dayContainerView)
    }
    
    
}
