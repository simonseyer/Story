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
        pageViewController.didMove(toParentViewController: self)
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
            registerForPreviewing(with: mapPreviewDelegate!, sourceView: tripView.mapView)
        }
        
        navigationItem.rightBarButtonItem = editButtonItem()
        
        tripView?.deleteButton.addTarget(self, action: #selector(deleteDay), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureNavigationController(true, initial: initial)
        initial = false
        model.observers.add(self)
        
        if model.days.isEmpty {
            setEditing(true, animated: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        configureNavigationController(false, initial: false)
        model.observers.remove(self)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        if editing == self.isEditing {
            return
        }
        
        super.setEditing(editing, animated: animated)
        pageViewController.setEditing(editing, animated: animated)
        navigationController?.hidesBarsOnTap = !editing
        
        if editing {
            navigationItem.setLeftBarButton(UIBarButtonItem(title: "New", style: .plain, target: self, action: #selector(addDay)), animated: true)
            navigationController?.setNavigationBarHidden(false, animated: true)
            updateStatusBarVisibility()
            UIView.animate(withDuration: animated ? 0.2 : 0.0, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {[unowned self] in
                self.tripView?.mapView.transform = CGAffineTransform(translationX: 0, y: TripView.mapViewHeight)
            }, completion: nil)
        } else {
            navigationItem.setLeftBarButton(nil, animated: true)
            UIView.animate(withDuration: animated ? 0.2 : 0.0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {[unowned self] in
                self.tripView?.mapView.transform = CGAffineTransform.identity
            }, completion: nil)
        }
        updateDeleteButton(animated)
    }
    
    func updateDeleteButton(_ animated: Bool) {
        UIView.animate(withDuration: animated ? 0.2 : 0.0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {[unowned self] in
            self.tripView?.deleteButton.alpha = self.isEditing && !self.model.days.isEmpty ? 1 : 0
        }, completion: nil)
    }
    
    func addDay() {
        pageViewController.addDay()
    }

    func deleteDay() {
        let deleteActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelActionButton: UIAlertAction = UIAlertAction(title: "Please Keep It", style: .cancel, handler: nil)
        deleteActionSheet.addAction(cancelActionButton)
        
        let deleteActionButton: UIAlertAction = UIAlertAction(title: "Delete Moment", style: .destructive) {[weak self] action -> Void in
            if let dayViewController = self?.pageViewController.currentViewController() {
                self?.model.removeDay(dayViewController.day)
            }
        }
        deleteActionSheet.addAction(deleteActionButton)
        
        present(deleteActionSheet, animated: true, completion: nil)
    }
}

// Status & Navigation Bar Handling
extension TripViewController: UINavigationControllerDelegate {
    
    private func configureNavigationController(_ configure: Bool, initial: Bool) {
        navigationController?.delegate = self
        navigationController?.hidesBarsOnTap = configure && !isEditing
        
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
            statusBarHidden = navigationController.isNavigationBarHidden
            let delay = statusBarHidden ? 0 : 0.05
            let animations = {[unowned self] in
                self.setNeedsStatusBarAppearanceUpdate()
            }
            UIView.animate(withDuration: statusBarAnimationDuration, delay: delay, options: UIViewAnimationOptions(), animations: animations, completion: nil)
        }
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return .fade
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return statusBarHidden
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .lightContent
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if !isEditing && viewController == self {
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
    
    private func addAnnotationForDay(_ day: Day) {
        if let latitude = day.image?.latitude, let longitude = day.image?.longitude {
            let annotation = DayAnnotation(latitude: latitude, longitude: longitude)
            dayAnnotations[day] = annotation
            tripView?.mapView.addAnnotation(annotation)
        }
    }
    
    private func removeAnnotationForDay(_ day: Day) {
        if let oldAnnotation = dayAnnotations[day] {
            tripView?.mapView.removeAnnotation(oldAnnotation)
        }
    }
    
    @objc(pageViewController:willTransitionToViewControllers:) func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let dayViewController = pendingViewControllers[0] as? DayViewController {
            lastDayViewController = currentDayViewController
            currentDayViewController = dayViewController
            centerMapView(dayViewController.day, animated: true)
        }
    }
    
    
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if !completed {
            currentDayViewController = lastDayViewController
            if let dayViewController = currentDayViewController {
                centerMapView(dayViewController.day, animated: true)
            }
        } else {
            currentDayViewController?.preview()
        }
    }
    
    private func centerMapView(_ dayModel: Day, animated: Bool) {
        if let latitude = dayModel.image?.latitude, let longitude = dayModel.image?.longitude {
            let day = DayAnnotation(latitude: latitude, longitude: longitude)
            if let mapView = tripView?.mapView {
                let viewRegion = MKCoordinateRegionMakeWithDistance(day.coordinate, 2000, 2000)
                mapView.setRegion(viewRegion, animated: animated)
            }
        }
    }
    
    func didInsertDay(_ day: Day, atIndex index: Int) {
        didUpdateDay(day, fromIndex: index, toIndex:  index)
        updateDeleteButton(true)
        updateLocation()
    }
    
    func didUpdateDay(_ day: Day, fromIndex: Int, toIndex: Int) {
        removeAnnotationForDay(day)
        addAnnotationForDay(day)
        updateLocation()
    }
    
    func didRemoveDay(_ day: Day, fromIndex index: Int) {
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
    
    let latitude: Double
    let longitude: Double
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    internal var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
}


@objc class DayMapPreviewDelegate : NSObject, UIViewControllerPreviewingDelegate {
    
    weak var baseViewController: UIViewController?
    weak var tripView: TripView?
    
    init(baseViewController: UIViewController, tripView: TripView) {
        self.baseViewController = baseViewController
        self.tripView = tripView
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let tripView = tripView {
            previewingContext.sourceRect = tripView.mapView.frame
            return MapViewController(viewRegion: tripView.mapView.region, annotations: tripView.mapView.annotations)
        }
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        if let baseViewController = baseViewController {
            baseViewController.show(viewControllerToCommit, sender: nil)
        }
    }
    
}
