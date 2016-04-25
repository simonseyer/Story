//
//  TripPageViewController.swift
//  Story
//
//  Created by COBI on 21.04.16.
//
//

import UIKit

class TripPageViewController : UIPageViewController, UIPageViewControllerDelegate {
    
    let dayStore: DayStore
    let viewModel: TripViewModel
    
    required init(model: DayStore) {
        self.dayStore = model
        self.viewModel = TripViewModel(trip: model)
        
        let options = [UIPageViewControllerOptionInterPageSpacingKey : 1]
        super.init(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: options)
        
        dataSource = viewModel
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        if let startingViewController = self.viewModel.viewControllerAtIndex(0) {
            setViewControllers([startingViewController], direction: .Forward, animated: false, completion: nil)
        }
    }
    
}

@objc class TripViewModel: NSObject, UIPageViewControllerDataSource {
    
    let trip: DayStore
    
    init(trip: DayStore) {
        self.trip = trip
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if let vc = viewController as? DayViewController, index = trip.days.indexOf(vc.day) {
            return viewControllerAtIndex(index - 1)
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if let vc = viewController as? DayViewController, index = trip.days.indexOf(vc.day) {
            return viewControllerAtIndex(index + 1)
        }
        return nil
    }
    
    func viewControllerAtIndex(index: Int) -> DayViewController? {
        guard index >= 0 && index < trip.days.count else {
            return nil
        }
        
        let viewController = DayViewController(model: trip.days[index])
        return viewController
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return trip.days.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
}