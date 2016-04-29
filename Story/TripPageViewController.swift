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
    var invalidateCommand: (Void -> Void)?
    
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
    
        for viewController in viewModel.dayViewControllers() + viewModel.additionalViewControllers {
            viewController.setEditing(editing, animated: animated)
        }
        
        if editing {
            if dayStore.days.isEmpty {
                addDay()
            }
        } else {
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
                self.setViewControllers(viewControllers, direction: .Reverse, animated: false, completion: nil)
            }
        }
    }
    
    override func setViewControllers(viewControllers: [UIViewController]?, direction: UIPageViewControllerNavigationDirection, animated: Bool, completion: ((Bool) -> Void)?) {
        if let currentViewController = viewControllers?.first as? DayViewController {
            viewModel.currentViewController = currentViewController
        }
        dispatch_async(dispatch_get_main_queue()) {
            super.setViewControllers(viewControllers, direction: direction, animated: animated) {[weak self] finished in
                completion?(finished)
                self?.invalidateCommand?()
            }
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
        setViewControllers([ viewModel.createAdditionalViewController()], direction: .Forward, animated: true, completion: nil)
    }
    
    func invalidatePageViewController() {
        if let currentViewController = viewControllers?.first {
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
    var viewControllers = NSHashTable.weakObjectsHashTable()
    var additionalViewControllers = [DayViewController]()
    var currentViewController: DayViewController?
    
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
        
        let viewController = createViewController(trip.days[index])
        viewControllers.addObject(viewController)
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
        if let viewController = currentViewController {
            if let index = trip.days.indexOf(viewController.day) {
                return index
            } else if let index = additionalViewControllers.indexOf(viewController) {
                return trip.days.count + index
            }
        }
        return 0
    }

    func dayViewControllers() -> [DayViewController] {
        return viewControllers.allObjects.map({ $0 as! DayViewController })
    }
}

extension TripPageViewController: DayStoreObserver {
    
    func didInsertDay(day: Day, atIndex index: Int) {
        var additionalViewControllerIndex = -1
        for (index, additionalViewController) in viewModel.additionalViewControllers.enumerate() {
            if additionalViewController.day == day {
                additionalViewControllerIndex = index
                break
            }
        }
        
        if additionalViewControllerIndex >= 0 {
            let dayViewController = viewModel.additionalViewControllers[additionalViewControllerIndex]
            viewModel.viewControllers.addObject(dayViewController)
            viewModel.additionalViewControllers.removeAtIndex(additionalViewControllerIndex)
        }
        
        invalidatePageViewController()
    }
    
    func didUpdateDay(day: Day, fromIndex: Int, toIndex: Int) {
        if fromIndex != toIndex {
            invalidatePageViewController()
        }
        for dayViewController in viewModel.dayViewControllers() {
            if dayViewController.day == day {
                dayViewController.day = day
            }
        }
    }
    
    func didRemoveDay(day: Day, fromIndex index: Int) {
        if let currentViewController = currentViewController() where currentViewController.day == day {
            if let previousViewController = viewModel.viewControllerAtIndex(index - 1) {
                self.setViewControllers([previousViewController], direction: .Reverse, animated: true, invalidate: true)
            } else if let nextViewController = viewModel.viewControllerAtIndex(index + 1) {
                self.setViewControllers([nextViewController], direction: .Forward, animated: true, invalidate: true)
            } else {
                self.setViewControllers([viewModel.createAdditionalViewController()], direction: .Reverse, animated: true, invalidate: true)
            }
        } else {
            invalidatePageViewController()
        }
    }
}

