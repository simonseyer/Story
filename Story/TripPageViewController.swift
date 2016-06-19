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
    var invalidateCommand: ((Void) -> Void)?
    
    required init(model: DayStore) {
        self.dayStore = model
        self.viewModel = TripViewModel(trip: model)
        
        let options = [UIPageViewControllerOptionInterPageSpacingKey : 1]
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: options)
        
        dataSource = viewModel
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        if let startingViewController = self.viewModel.viewControllerAtIndex(0) {
            setViewControllers([startingViewController], direction: .forward, animated: false, completion: nil)
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
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
            if viewModel.additionalViewControllers.contains(currentViewController()!) {
                viewModel.additionalViewControllers.removeAll()
                if let dayViewController = viewModel.viewControllerAtIndex(dayStore.days.count - 1) {
                    setViewControllers([dayViewController], direction: .reverse, animated: dayViewController.day != currentViewController()?.day, invalidate: true)
                } else {
                    setViewControllers([viewModel.createAdditionalViewController()], direction: .forward, animated: false, completion: nil)
                }
            } else {
                viewModel.additionalViewControllers.removeAll()
                invalidatePageViewController()
            }
        }
    }
    
    func setViewControllers(_ viewControllers: [UIViewController]?, direction: UIPageViewControllerNavigationDirection, animated: Bool, invalidate: Bool) {
        setViewControllers(viewControllers, direction: .reverse, animated: animated) {[unowned self] completed in
            if animated && invalidate {
                self.setViewControllers(viewControllers, direction: .reverse, animated: false, completion: nil)
            }
        }
    }
    
    override func setViewControllers(_ viewControllers: [UIViewController]?, direction: UIPageViewControllerNavigationDirection, animated: Bool, completion: ((Bool) -> Void)?) {
        if let currentViewController = viewControllers?.first as? DayViewController {
            viewModel.currentViewController = currentViewController
        }
        DispatchQueue.main.async {
            super.setViewControllers(viewControllers, direction: direction, animated: animated) {[weak self] finished in
                completion?(finished)
                self?.invalidateCommand?()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dayStore.observers.add(self)
        invalidatePageViewController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dayStore.observers.remove(self)
    }

    func addDay() {
        setViewControllers([viewModel.createAdditionalViewController()], direction: .forward, animated: true, completion: nil)
    }
    
    func invalidatePageViewController() {
        if let currentViewController = viewControllers?.first {
            setViewControllers([currentViewController], direction: .reverse, animated: false, completion: nil)
        }
    }
    
    func currentViewController() -> DayViewController? {
        return viewControllers?.first as? DayViewController
    }
}

@objc class TripViewModel: NSObject, UIPageViewControllerDataSource {
    
    let trip: DayStore
    var editing =  false
    var viewControllers = HashTable<AnyObject>.weakObjects()
    var additionalViewControllers = [DayViewController]()
    var currentViewController: DayViewController?
    
    init(trip: DayStore) {
        self.trip = trip
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let dayViewController = viewController as? DayViewController else {
            return nil
        }
        
        if let index = trip.days.index(of: dayViewController.day) {
            return viewControllerAtIndex(index - 1)
        } else if let index = additionalViewControllers.index(of: dayViewController), previousViewController = additionalViewControllerAtIndex(index - 1) {
            return previousViewController
        } else {
            return viewControllerAtIndex(trip.days.count - 1)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let dayViewController = viewController as? DayViewController else {
            return nil
        }
        
        if let index = trip.days.index(of: dayViewController.day), nextViewController = viewControllerAtIndex(index + 1) {
            return nextViewController
        } else if let index = additionalViewControllers.index(of: dayViewController) {
            return additionalViewControllerAtIndex(index + 1)
        } else {
            return additionalViewControllerAtIndex(0)
        }
    }
    
    func viewControllerAtIndex(_ index: Int) -> DayViewController? {
        guard index >= 0 && index < trip.days.count else {
            return nil
        }
        
        let viewController = createViewController(trip.days[index])
        viewControllers.add(viewController)
        return viewController
    }
    
    func additionalViewControllerAtIndex(_ index: Int) -> DayViewController? {
        guard index >= 0 && index < additionalViewControllers.count else {
            return nil
        }
        return additionalViewControllers[index]
    }
    
    func createViewController(_ day: Day) -> DayViewController {
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
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return trip.days.count + additionalViewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        if let viewController = currentViewController {
            if let index = trip.days.index(of: viewController.day) {
                return index
            } else if let index = additionalViewControllers.index(of: viewController) {
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
    
    func didInsertDay(_ day: Day, atIndex index: Int) {
        var additionalViewControllerIndex = -1
        for (index, additionalViewController) in viewModel.additionalViewControllers.enumerated() {
            if additionalViewController.day == day {
                additionalViewControllerIndex = index
                break
            }
        }
        
        if additionalViewControllerIndex >= 0 {
            let dayViewController = viewModel.additionalViewControllers[additionalViewControllerIndex]
            viewModel.viewControllers.add(dayViewController)
            viewModel.additionalViewControllers.remove(at: additionalViewControllerIndex)
        }
        
        invalidatePageViewController()
    }
    
    func didUpdateDay(_ day: Day, fromIndex: Int, toIndex: Int) {
        if fromIndex != toIndex {
            invalidatePageViewController()
        }
        for dayViewController in viewModel.dayViewControllers() {
            if dayViewController.day == day {
                dayViewController.day = day
            }
        }
    }
    
    func didRemoveDay(_ day: Day, fromIndex index: Int) {
        if let currentViewController = currentViewController() where currentViewController.day == day {
            if let previousViewController = viewModel.viewControllerAtIndex(index - 1) {
                self.setViewControllers([previousViewController], direction: .reverse, animated: true, invalidate: true)
            } else if let nextViewController = viewModel.viewControllerAtIndex(index + 1) {
                self.setViewControllers([nextViewController], direction: .forward, animated: true, invalidate: true)
            } else {
                self.setViewControllers([viewModel.createAdditionalViewController()], direction: .reverse, animated: true, invalidate: true)
            }
        } else {
            invalidatePageViewController()
        }
    }
}

