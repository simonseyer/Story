//
//  SingleLocationManager.swift
//  Story
//
//  Created by COBI on 24.04.16.
//
//

import CoreLocation

enum SingleLocationManagerError: Int {
    case authorizationDenied
    case locationNotAvailable
}

extension SingleLocationManagerError {
    
    static let domain = "SingleLocationManagerErrorDomain"
    
    func error(underlyingError: NSError? = nil) -> NSError {
        var userInfo : [String : AnyObject]? = nil
        if let underlyingError = underlyingError {
            userInfo = [NSUnderlyingErrorKey : underlyingError]
        }
        
        return NSError(domain: SingleLocationManagerError.domain,
                       code: self.rawValue,
                       userInfo: userInfo)
    }
}

class SingleLocationManager: NSObject {
    
    private var locationManager: CLLocationManager?
    
    typealias LocationClosure = ((location: CLLocation?, error: NSError?)->())
    private var completionBlock: LocationClosure?

    func fetchLocation(withCompletionBlock completion: LocationClosure) {
        completionBlock = completion
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        
        startFetch()
    }
    
    private func startFetch() {
        if let aLocationManager = locationManager {
            if CLLocationManager.authorizationStatus() == .notDetermined {
                aLocationManager.requestWhenInUseAuthorization()
            } else {
                locationManager(aLocationManager, didChangeAuthorization: CLLocationManager.authorizationStatus())
            }
        }
    }
    
    private func completeFetch(withLocation location: CLLocation?, error: NSError?) {
        completionBlock?(location: location, error: error)
        locationManager = nil
    }
}

extension SingleLocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            fallthrough
        case .authorizedWhenInUse:
            self.locationManager?.requestLocation()
        case .denied:
            fallthrough
        case .restricted:
            completeFetch(withLocation: nil, error: SingleLocationManagerError.authorizationDenied.error())
        default:
            break
        }
    }
    
    @objc(locationManager:didUpdateLocations:) internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        completeFetch(withLocation: location, error: nil)
    }
    
    internal func locationManager(_ manager: CLLocationManager, didFailWithError error: NSError) {
        let wrappedError = SingleLocationManagerError.locationNotAvailable.error(underlyingError: error)
        completeFetch(withLocation: nil, error: wrappedError)
    }
    
}
