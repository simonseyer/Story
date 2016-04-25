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
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        viewModel.editing = editing
    
        for viewController in viewModel.viewControllers.values {
            viewController.setEditing(editing, animated: animated)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        dayStore.observers.addObject(viewModel)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        dayStore.observers.removeObject(viewModel)
    }

}

@objc class TripViewModel: NSObject, UIPageViewControllerDataSource {
    
    let trip: DayStore
    var editing =  false
    var viewControllers = [Int : DayViewController]()
    
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
        viewController.setEditing(editing, animated: false)
        
        viewController.changeCommand = {[weak self] day in
            self?.trip.storeDay(day)
        }
        
        viewControllers[index] = viewController
        return viewController
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return trip.days.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
}

extension TripViewModel: DayStoreObserver {
    
    func didInsertDay(day: Day, atIndex index: Int) {
        
    }
    
    func didUpdateDay(day: Day, atIndex index: Int) {
        if let vc = viewControllers[index] {
            vc.day = day
        }
    }
    
    func didRemoveDay(day: Day, fromIndex index: Int) {
        
    }
}

