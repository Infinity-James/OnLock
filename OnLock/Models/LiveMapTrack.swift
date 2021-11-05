//
//  LiveTrack.swift
//  OnLock
//
//  Created by Lewis Valaitis on 15/03/2021.
//

import MapKit

// MARK: - Live Track
public struct LiveMapTrack {
    public var coordinates: [CLLocationCoordinate2D]
}

extension LiveMapTrack {
    public func getPolyLine(with locations: [CLLocationCoordinate2D]) -> MKPolyline {
        MKPolyline(coordinates: locations, count: locations.count)
    }
}
