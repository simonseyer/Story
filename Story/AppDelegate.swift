//
//  AppDelegate.swift
//  Story
//
//  Created by COBI on 19.04.16.
//
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private let tripStore = TripStore()
    private var dayStore: DayStore?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let navigationbar = UINavigationBar.appearance()
        navigationbar.titleTextAttributes = [NSFontAttributeName : UIFont(name: ViewConstants.boldTextFontName, size: 20)!, NSForegroundColorAttributeName : UIColor(hexValue: ViewConstants.tintTextColorCode)]
        navigationbar.tintColor = UIColor(hexValue: ViewConstants.tintTextColorCode)
        let barButtonItem = UIBarButtonItem.appearance()
        barButtonItem.setTitleTextAttributes([NSFontAttributeName : UIFont(name: ViewConstants.textFontName, size: 20)!, NSForegroundColorAttributeName : UIColor(hexValue: ViewConstants.tintTextColorCode)], for: UIControlState())
        
        let pageControl = UIPageControl.appearance();
        pageControl.pageIndicatorTintColor = UIColor(hexValue: ViewConstants.textColorCode);
        pageControl.currentPageIndicatorTintColor = UIColor(hexValue: ViewConstants.tintTextColorCode);
        
        self.window = UIWindow(frame: UIScreen.main().bounds)
        self.window?.backgroundColor = UIColor.white()
        
        //TripStore.delete()
        tripStore.load()
        tripStore.loadDemoDataIfNeeded()
        
        let tripListViewController = TripListViewController(model: tripStore)
        tripListViewController.selectionCommand = {[unowned self] trip in
            self.dayStore = self.tripStore.dayStoreForTrip(trip)
            let tripViewController = TripViewController(model: self.dayStore!)
            tripListViewController.navigationController?.pushViewController(tripViewController, animated: true)
        }
        
        self.window?.rootViewController = UINavigationController(rootViewController: tripListViewController)
        self.window?.makeKeyAndVisible()
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        tripStore.save()
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

