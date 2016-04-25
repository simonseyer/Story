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
    let model: DayStore
    var statusBarHidden = false
    
    let pageViewController: TripPageViewController
    let statusBarAnimationDuration = 0.4
    
    var disappearCommand: (Void -> Void)?
    
    init(model: DayStore) {
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
        
        configureNavigationController(true)
        
        pageViewController.delegate = self

        addMarkers()
        if let day = model.days.first {
            centerMapView(day, animated: false)
        }
        
        navigationItem.rightBarButtonItem = editButtonItem()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        configureNavigationController(false)
        disappearCommand?()
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        pageViewController.setEditing(editing, animated: animated)
        navigationController?.hidesBarsOnTap = !editing
    }

}

// Status & Navigation Bar Handling
extension TripViewController {
    
    private func configureNavigationController(configure: Bool) {
        navigationController?.hidesBarsOnTap = configure
        navigationController?.setNavigationBarHidden(configure, animated: true)
        didTap()
        
        if configure {
            navigationItem.title = model.trip.name
            navigationController?.barHideOnTapGestureRecognizer.addTarget(self, action: #selector(didTap))
        }
    }
    
    func didTap() {
        statusBarHidden = !statusBarHidden
        let delay = statusBarHidden ? 0 : 0.05
        let animations = {[unowned self] in
            self.setNeedsStatusBarAppearanceUpdate()
        }
        UIView.animateWithDuration(statusBarAnimationDuration, delay: delay, options: UIViewAnimationOptions(), animations: animations, completion: nil)
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return .Fade
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
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        if let dayViewController = pendingViewControllers[0] as? DayViewController {
            centerMapView(dayViewController.day, animated: true)
        }
    }
    
    private func centerMapView(dayModel: Day, animated: Bool) {
        let day = DayAnnotation(day: dayModel)
        if let mapView = tripView?.mapView {
            let viewRegion = MKCoordinateRegionMakeWithDistance(day.coordinate, 500, 500)
            mapView.setRegion(viewRegion, animated: animated)
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