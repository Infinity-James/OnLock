//
//  LocationTracker.swift
//  OnLock
//
//  Created by Lewis Valaitis on 21/03/2021.
//

import Foundation
import MapKit
import SwiftUI

// MARK: - Location Tracker Delegate
internal protocol LocationTrackerDelegate {
    func valueChanged(for coordinates: [CLLocationCoordinate2D])
}

// MARK: - Location Tracker
internal final class LocationTracker: NSObject {
    internal var delegate: LocationTrackerDelegate?
    private let locationManager = CLLocationManager()
    private var coordinates: [CLLocationCoordinate2D] = [] {
        didSet {
            delegate?.valueChanged(for: coordinates)
        }
    }
    private let minimumTrackDistance: Double
    
    // MARK: Initialiser
    init(meterAccuracy: Double, minimumTrackDistance: Double) {
        locationManager.desiredAccuracy = meterAccuracy
        self.minimumTrackDistance = minimumTrackDistance
    }
}

// MARK: Methods
extension LocationTracker {
    internal func startUpdatingLocation() {
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    internal func stopUpdatingLocation() { locationManager.stopUpdatingLocation() }
}

// MARK: CLLocationManagerDelegate
extension LocationTracker: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last,
              newLocation.horizontalAccuracy < manager.desiredAccuracy else {
            return
        }
        
        guard !coordinates.isEmpty else {
            coordinates.append(newLocation.coordinate)
            return
        }
        
        
        guard let previousLocation = coordinates.last,
              newLocation.coordinate.distance(to: previousLocation) != 0,
              newLocation.coordinate.distance(to: previousLocation) >= minimumTrackDistance else {
            return
        }
        
        coordinates.append(newLocation.coordinate)
    }
}
