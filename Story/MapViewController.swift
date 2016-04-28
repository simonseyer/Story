//
//  MapViewController.swift
//  Story
//
//  Created by COBI on 28.04.16.
//
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    let statusBarAnimationDuration = 0.4
    
    var mapView = MKMapView()
    
    let annotations: [MKAnnotation]
    let viewRegion: MKCoordinateRegion
    var statusBarHidden: Bool = false
    
    init(viewRegion: MKCoordinateRegion, annotations: [MKAnnotation]) {
        self.viewRegion = viewRegion
        self.annotations = annotations
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(mapView)
        
        LayoutUtils.fullInSuperview(mapView, superView: self.view)
        
        automaticallyAdjustsScrollViewInsets  = false

        mapView.addAnnotations(annotations)
        mapView.setRegion(viewRegion, animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        configureNavigationController(true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        configureNavigationController(false)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return statusBarHidden
    }
    
    // TODO: copy & paste
    
    private func configureNavigationController(configure: Bool) {
        if configure {
            Background.delay(0.5) {
                self.navigationController?.hidesBarsOnTap = configure
            }
        } else {
            navigationController?.hidesBarsOnTap = configure
        }
        
        if configure {
            navigationController?.barHideOnTapGestureRecognizer.addTarget(self, action: #selector(updateStatusBarVisibility))
            updateStatusBarVisibility()
        } else {
            navigationController?.setNavigationBarHidden(false, animated: true)
            navigationController?.barHideOnTapGestureRecognizer.removeTarget(self, action: #selector(updateStatusBarVisibility))
        }
    }
    
    func updateStatusBarVisibility() {
        if let navigationController = navigationController {
            statusBarHidden = navigationController.navigationBarHidden
            let delay = statusBarHidden ? 0 : 0.05
            let animations = {[unowned self] in
                self.setNeedsStatusBarAppearanceUpdate()
            }
            UIView.animateWithDuration(statusBarAnimationDuration, delay: delay, options: UIViewAnimationOptions(), animations: animations, completion: nil)
        }
    }
    
}
