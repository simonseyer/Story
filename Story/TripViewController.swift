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
    private weak var lastDayViewController: DayViewController?
    private var mapPreviewDelegate: DayMapPreviewDelegate?
    
    private var initial = true
    
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
        
        if let tripView = tripView {
            //tripView.mapView.userInteractionEnabled = true
            mapPreviewDelegate = DayMapPreviewDelegate(baseViewController: self, tripView: tripView)
            registerForPreviewingWithDelegate(mapPreviewDelegate!, sourceView: tripView.mapView)
        }
        
        navigationItem.rightBarButtonItem = editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        configureNavigationController(true, initial: initial)
        initial = false
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
            navigationController?.barHideOnTapGestureRecognizer.addTarget(self, action: #selector(updateStatusBarVisibility))
            
            if initial {
                navigationController?.setNavigationBarHidden(true, animated: true)
                updateStatusBarVisibility()
            } else {
                updateStatusBarVisibility()
            }
        } else {
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
            lastDayViewController = currentDayViewController
            currentDayViewController = dayViewController
            centerMapView(dayViewController.day, animated: true)
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if !completed {
            currentDayViewController = lastDayViewController
            if let dayViewController = currentDayViewController {
                centerMapView(dayViewController.day, animated: true)
            }
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


@objc class DayMapPreviewDelegate : NSObject, UIViewControllerPreviewingDelegate {
    
    let baseViewController: UIViewController
    let tripView: TripView
    
    init(baseViewController: UIViewController, tripView: TripView) {
        self.baseViewController = baseViewController
        self.tripView = tripView
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        previewingContext.sourceRect = tripView.mapView.frame
        return MapViewController(viewRegion: tripView.mapView.region, annotations: tripView.mapView.annotations)
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        baseViewController.showViewController(viewControllerToCommit, sender: nil)
    }
    
}