//
//  TripViewController.swift
//  Story
//
//  Created by COBI on 21.04.16.
//
//

import UIKit
import CoreLocation
import MapKit

class TripViewController: UIViewController, UIPageViewControllerDelegate {
    
    var tripView: TripView?
    let model: Trip
    var statusBarHidden = false
    
    let pageViewController: TripPageViewController
    let statusBarAnimationDuration = 0.25
    
    init(model: Trip) {
        self.model = model
        pageViewController = TripPageViewController(model: model)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        tripView = TripView()
        view = tripView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChildViewController(pageViewController)
        pageViewController.didMoveToParentViewController(self)
        tripView?.setDayView(pageViewController.view)
        
        configureNavigationController()
        
        pageViewController.delegate = self

        addMarkers()
        if let day = model.days.first {
            centerMapView(day, animated: false)
        }
    }
    
    private func configureNavigationController() {
        self.navigationItem.title = model.name
        
        self.navigationController?.hidesBarsOnTap = true
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.barHideOnTapGestureRecognizer.addTarget(self, action: #selector(didTap))
    }
    
}

// Status Bar Handling
extension TripViewController {
    
    func didTap() {
        statusBarHidden = !statusBarHidden
        UIView.animateWithDuration(statusBarAnimationDuration) {[unowned self] in
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return .Slide
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return statusBarHidden
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}

// MapView Handling
extension TripViewController {
    
    private func addMarkers() {
        for day in model.days {
            tripView?.mapView.addAnnotation(DayAnnotation(day: day))
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let viewControllers = pageViewController.viewControllers, dayViewController = viewControllers[0] as? DayViewController {
            centerMapView(dayViewController.day, animated: true)
        }
    }
    
    private func centerMapView(dayModel: Day, animated: Bool) {
        let day = DayAnnotation(day: dayModel)
        if let mapView = tripView?.mapView {
            let viewRegion = MKCoordinateRegionMakeWithDistance(day.coordinate, 500, 500)
            let region = mapView.regionThatFits(viewRegion)
            mapView.setRegion(region, animated: animated)
        }
    }
    
}


@objc class DayAnnotation : NSObject, MKAnnotation {
    
    let day: Day
    
    init(day: Day) {
        self.day = day
    }
    
    internal  var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(day.image.latitude, day.image.longitude)
    }
}