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
    
    private var dayAnnotations = [Day : DayAnnotation]()
    private weak var currentDayViewController: DayViewController?
    
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
        
        pageViewController.delegate = self

        addMarkers()
        if let day = model.days.first {
            centerMapView(day, animated: false)
        }
        
        navigationItem.rightBarButtonItem = editButtonItem()
        configureNavigationController(true, initial: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        configureNavigationController(true, initial: false)
        model.observers.addObject(self)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        configureNavigationController(false, initial: false)
        model.observers.removeObject(self)
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        pageViewController.setEditing(editing, animated: animated)
        navigationController?.hidesBarsOnTap = !editing
        
        if editing {
            navigationItem.setLeftBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(addDay)), animated: true)
        } else {
            navigationItem.setLeftBarButtonItem(nil, animated: true)
        }
    }
    
    func addDay() {
        pageViewController.addDay()
    }

}

// Status & Navigation Bar Handling
extension TripViewController {
    
    private func configureNavigationController(configure: Bool, initial: Bool) {
        navigationController?.hidesBarsOnTap = configure
        
        if configure {
            navigationItem.title = model.trip.name
            navigationController?.barHideOnTapGestureRecognizer.addTarget(self, action: #selector(didTap))
            
            if initial {
                navigationController?.setNavigationBarHidden(true, animated: true)
                didTap()
            }
        } else {
            navigationController?.setNavigationBarHidden(false, animated: true)
            navigationController?.barHideOnTapGestureRecognizer.removeTarget(self, action: #selector(didTap))
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
extension TripViewController : DayStoreObserver {
    
    private func addMarkers() {
        for day in model.days {
            addAnnotationForDay(day)
        }
    }
    
    private func addAnnotationForDay(day: Day) {
        if let image = day.image {
            let annotation = DayAnnotation(image: image)
            dayAnnotations[day] = annotation
            tripView?.mapView.addAnnotation(annotation)
        }
    }
    
    private func removeAnnotationForDay(day: Day) {
        if let oldAnnotation = dayAnnotations[day] {
            tripView?.mapView.removeAnnotation(oldAnnotation)
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        if let dayViewController = pendingViewControllers[0] as? DayViewController {
            currentDayViewController = dayViewController
            centerMapView(dayViewController.day, animated: true)
        }
    }
    
    private func centerMapView(dayModel: Day, animated: Bool) {
        if let image = dayModel.image {
            let day = DayAnnotation(image: image)
            if let mapView = tripView?.mapView {
                let viewRegion = MKCoordinateRegionMakeWithDistance(day.coordinate, 500, 500)
                mapView.setRegion(viewRegion, animated: animated)
            }
        }
    }
    
    func didInsertDay(day: Day, atIndex index: Int) {
        didUpdateDay(day, fromIndex: index, toIndex:  index)
    }
    
    func didUpdateDay(day: Day, fromIndex: Int, toIndex: Int) {
        removeAnnotationForDay(day)
        addAnnotationForDay(day)
        
        if currentDayViewController?.day == day {
            centerMapView(day, animated: true)
        }
    }
    
    func didRemoveDay(day: Day, fromIndex index: Int) {
        removeAnnotationForDay(day)
    }

}


@objc class DayAnnotation : NSObject, MKAnnotation {
    
    let image: Image
    
    init(image: Image) {
        self.image = image
    }
    
    internal var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(image.latitude, image.longitude)
    }
}