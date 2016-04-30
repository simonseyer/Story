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
        pageViewController.invalidateCommand = {[weak self] in
            self?.updateLocation()
            self?.updateDeleteButton(true)
        }

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
        
        tripView?.deleteButton.addTarget(self, action: #selector(deleteDay), forControlEvents: .TouchUpInside)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        configureNavigationController(true, initial: initial)
        initial = false
        model.observers.addObject(self)
        
        if model.days.isEmpty {
            setEditing(true, animated: false)
        }
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
            navigationItem.setLeftBarButtonItem(UIBarButtonItem(title: "New", style: .Plain, target: self, action: #selector(addDay)), animated: true)
            navigationController?.setNavigationBarHidden(false, animated: false)
            updateStatusBarVisibility()
            UIView.animateWithDuration(animated ? 0.2 : 0.0, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {[unowned self] in
                self.tripView?.mapView.transform = CGAffineTransformMakeTranslation(0, TripView.mapViewHeight)
            }, completion: nil)
        } else {
            navigationItem.setLeftBarButtonItem(nil, animated: true)
            UIView.animateWithDuration(animated ? 0.2 : 0.0, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {[unowned self] in
                self.tripView?.mapView.transform = CGAffineTransformIdentity
            }, completion: nil)
        }
        updateDeleteButton(animated)
    }
    
    func updateDeleteButton(animated: Bool) {
        UIView.animateWithDuration(animated ? 0.2 : 0.0, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {[unowned self] in
            self.tripView?.deleteButton.alpha = self.editing && !self.model.days.isEmpty ? 1 : 0
        }, completion: nil)
    }
    
    func addDay() {
        pageViewController.addDay()
    }

    func deleteDay() {
        let deleteActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let cancelActionButton: UIAlertAction = UIAlertAction(title: "Please Keep It", style: .Cancel, handler: nil)
        deleteActionSheet.addAction(cancelActionButton)
        
        let deleteActionButton: UIAlertAction = UIAlertAction(title: "Delete Moment", style: .Destructive) {[weak self] action -> Void in
            if let dayViewController = self?.pageViewController.currentViewController() {
                self?.model.removeDay(dayViewController.day)
            }
        }
        deleteActionSheet.addAction(deleteActionButton)
        
        presentViewController(deleteActionSheet, animated: true, completion: nil)
    }
}

// Status & Navigation Bar Handling
extension TripViewController: UINavigationControllerDelegate {
    
    private func configureNavigationController(configure: Bool, initial: Bool) {
        navigationController?.delegate = self
        navigationController?.hidesBarsOnTap = configure
        
        if configure {
            navigationItem.title = model.trip.name
            navigationController?.barHideOnTapGestureRecognizer.addTarget(self, action: #selector(updateStatusBarVisibility))
            
            updateStatusBarVisibility()
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
    
    func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        if viewController == self {
            navigationController.setNavigationBarHidden(true, animated: true)
            updateStatusBarVisibility()
        }
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
        updateDeleteButton(true)
        updateLocation()
    }
    
    func didUpdateDay(day: Day, fromIndex: Int, toIndex: Int) {
        removeAnnotationForDay(day)
        addAnnotationForDay(day)
        updateLocation()
    }
    
    func didRemoveDay(day: Day, fromIndex index: Int) {
        removeAnnotationForDay(day)
        updateDeleteButton(true)
    }

    func updateLocation() {
        if let dayViewController = pageViewController.currentViewController() {
            centerMapView(dayViewController.day, animated: true)
        }
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
    
    weak var baseViewController: UIViewController?
    weak var tripView: TripView?
    
    init(baseViewController: UIViewController, tripView: TripView) {
        self.baseViewController = baseViewController
        self.tripView = tripView
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let tripView = tripView {
            previewingContext.sourceRect = tripView.mapView.frame
            return MapViewController(viewRegion: tripView.mapView.region, annotations: tripView.mapView.annotations)
        }
        return nil
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        if let baseViewController = baseViewController {
            baseViewController.showViewController(viewControllerToCommit, sender: nil)
        }
    }
    
}