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
    
        for viewController in viewModel.viewControllers.values + viewModel.additionalViewControllers {
            viewController.setEditing(editing, animated: animated)
        }
        
        if !editing {
            if let currentViewController = currentViewController() where viewModel.additionalViewControllers.contains(currentViewController) {
                viewModel.additionalViewControllers.removeAll()
                if let dayViewController = viewModel.viewControllerAtIndex(dayStore.days.count - 1) {
                    setViewControllers([dayViewController], direction: .Reverse, animated: true, invalidate: true)
                }
            } else {
                viewModel.additionalViewControllers.removeAll()
            }
        }
    }
    
    func setViewControllers(viewControllers: [UIViewController]?, direction: UIPageViewControllerNavigationDirection, animated: Bool, invalidate: Bool) {
        setViewControllers(viewControllers, direction: .Reverse, animated: true) {[unowned self] completed in
            if invalidate {
                self.viewModel.clearCache()
                self.setViewControllers(viewControllers, direction: .Reverse, animated: false, completion: nil)
            }
        }
    }
    
    override func setViewControllers(viewControllers: [UIViewController]?, direction: UIPageViewControllerNavigationDirection, animated: Bool, completion: ((Bool) -> Void)?) {
        dispatch_async(dispatch_get_main_queue()) {
            super.setViewControllers(viewControllers, direction: direction, animated: animated, completion: completion)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        dayStore.observers.addObject(self)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        dayStore.observers.removeObject(self)
    }

    func addDay() {
        setViewControllers([viewModel.createAdditionalViewController()], direction: .Forward, animated: true, completion: nil)
    }
    
    func invalidatePageViewController() {
        if let currentViewController = viewControllers?.first {
            viewModel.clearCache()
            setViewControllers([currentViewController], direction: .Reverse, animated: false, completion: nil)
        }
    }
    
    func currentViewController() -> DayViewController? {
        return viewControllers?.first as? DayViewController
    }
}

@objc class TripViewModel: NSObject, UIPageViewControllerDataSource {
    
    let trip: DayStore
    var editing =  false
    var viewControllers = [Int : DayViewController]()
    var additionalViewControllers = [DayViewController]()
    
    init(trip: DayStore) {
        self.trip = trip
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let dayViewController = viewController as? DayViewController else {
            return nil
        }
        
        if let index = trip.days.indexOf(dayViewController.day) {
            return viewControllerAtIndex(index - 1)
        } else if let index = additionalViewControllers.indexOf(dayViewController), previousViewController = additionalViewControllerAtIndex(index - 1) {
            return previousViewController
        } else {
            return viewControllerAtIndex(trip.days.count - 1)
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        guard let dayViewController = viewController as? DayViewController else {
            return nil
        }
        
        if let index = trip.days.indexOf(dayViewController.day), nextViewController = viewControllerAtIndex(index + 1) {
            return nextViewController
        } else if let index = additionalViewControllers.indexOf(dayViewController) {
            return additionalViewControllerAtIndex(index + 1)
        } else {
            return additionalViewControllerAtIndex(0)
        }
    }
    
    func viewControllerAtIndex(index: Int) -> DayViewController? {
        guard index >= 0 && index < trip.days.count else {
            return nil
        }
        
        if let viewController = viewControllers[index] {
            return viewController
        }
        
        let viewController = createViewController(trip.days[index])
        viewControllers[index] = viewController
        return viewController
    }
    
    func additionalViewControllerAtIndex(index: Int) -> DayViewController? {
        guard index >= 0 && index < additionalViewControllers.count else {
            return nil
        }
        return additionalViewControllers[index]
    }
    
    func createViewController(day: Day) -> DayViewController {
        let viewController = DayViewController(model: day)
        viewController.setEditing(editing, animated: false)
        
        viewController.changeCommand = {[weak self] day in
            self?.trip.storeDay(day)
        }
        
        return viewController
    }
    
    func createAdditionalViewController()  -> DayViewController {
        let additionalViewController = createViewController(Day(text: nil, image: nil))
        additionalViewControllers.append(additionalViewController)
        return additionalViewController
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return trip.days.count + additionalViewControllers.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0 // TODO improve
    }
    
    func clearCache() {
        viewControllers = [:]
    }

}

extension TripPageViewController: DayStoreObserver {
    
    func didInsertDay(day: Day, atIndex index: Int) {
        invalidatePageViewController()
        
        var additionalViewControllerIndex = -1
        for (index, additionalViewController) in viewModel.additionalViewControllers.enumerate() {
            if additionalViewController.day == day {
                additionalViewControllerIndex = index
                break
            }
        }
        
        if additionalViewControllerIndex >= 0 {
            let dayViewController = viewModel.additionalViewControllers[additionalViewControllerIndex]
            dayViewController.day = day
            viewModel.viewControllers[index] = dayViewController
            
            viewModel.additionalViewControllers.removeAtIndex(additionalViewControllerIndex)
        }
    }
    
    func didUpdateDay(day: Day, fromIndex: Int, toIndex: Int) {
        if fromIndex != toIndex {
            invalidatePageViewController()
        }
        if let vc = viewModel.viewControllers[toIndex] {
            vc.day = day
        }
    }
    
    func didRemoveDay(day: Day, fromIndex index: Int) {
        if let currentViewController = currentViewController() where currentViewController.day == day {
            if let previousViewController = viewModel.viewControllerAtIndex(index - 1) {
                self.setViewControllers([previousViewController], direction: .Reverse, animated: false, invalidate: true)
            } else if let nextViewController = viewModel.viewControllerAtIndex(index + 1) {
                self.setViewControllers([nextViewController], direction: .Forward, animated: false, invalidate: true)
            } else {
                self.setViewControllers([], direction: .Reverse, animated: false, invalidate: true)
            }
        } else {
            invalidatePageViewController()
        }
    }
}

