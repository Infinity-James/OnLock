//
//  MapData.swift
//  OnLock
//
//  Created by James Valaitis on 13/03/2021.
//

import Combine
import Foundation
import MapKit
import SwiftUI

//  MARK: Map Data
internal final class MapData: NSObject, ObservableObject {
	@Published private var tracks: [MapTrack] = []
    @Published private var liveMapTrack: LiveMapTrack?
//	internal var boundingRect: MKMapRect {
//		tracks
//			.map { $0.polygon.boundingMapRect }
//			.reduce(MKMapRect.null) { $0.union($1) }
//	}
    private let locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = 15
        return locationManager
    }()

	internal func load() {
		DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
			let loadedTracks = Track.loadTestData()
				.map { track in MapTrack(track: track, polygon: MKPolygon(coordinates: track.clCoordinates, count: track.coordinates.count)) }
			DispatchQueue.main.async { tracks = loadedTracks }
		}
        locationManager.delegate = self
        DispatchQueue.main.async { [unowned self] in locationManager.startUpdatingLocation() }
	}

	internal func addPolygons(to map: MKMapView) {
		map.addOverlays(tracks.map { $0.polygon })
	}
    
    internal func addPolyLines(to map: MKMapView) {
        guard let liveMapTrack = liveMapTrack else { return }
        let coordinateRegion = MKCoordinateRegion(
            center: liveMapTrack.coordinates.first!,
          latitudinalMeters: 300,
          longitudinalMeters: 300)
        map.setRegion(coordinateRegion, animated: true)
        map.addOverlay(MKPolyline(coordinates: liveMapTrack.coordinates, count: liveMapTrack.coordinates.count))
    }

	internal func track(for polygon: MKPolygon) -> Track? {
		tracks.first(where: { $0.polygon == polygon })?.track
	}

	private typealias TrackPointDistance = (track: Track, point: CLLocationCoordinate2D, distance: CLLocationDistance)
	internal typealias TrackPoint = (track: Track, point: CLLocationCoordinate2D)

	internal func closest(to coordinate: CLLocationCoordinate2D) -> TrackPoint? {
		let closest = tracks
			.compactMap { track -> TrackPointDistance? in
				let closest = track.track.clCoordinates
					.map { (point: $0, distance: $0.distance(to: coordinate)) }
					.min { c1, c2 in c1.distance < c2.distance }
				return closest.flatMap { (track.track, $0.point, $0.distance) }
			}
			.min { tc1, tc2 in tc1.distance < tc2.distance }

		if let closest = closest {
			return (closest.track, closest.point)
		} else { return nil }
	}
}
//  MARK: Core Location Manager Delegate
extension MapData: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last,
              newLocation.horizontalAccuracy < manager.desiredAccuracy else { return }
        if liveMapTrack == nil {
            liveMapTrack = LiveMapTrack(coordinates: [newLocation.coordinate])
            return
        }
        guard let liveMapTrack = liveMapTrack,
              let previousCoordinate = liveMapTrack.coordinates.last, 
              newLocation.coordinate.distance(to: previousCoordinate) > 10 else { return }
        self.liveMapTrack!.coordinates.append(newLocation.coordinate)
    }
}


//  MARK: Map Track
private struct MapTrack: Hashable {
	let track: Track
	let polygon: MKPolygon
}

// MARK: Track + Core Location
private extension Track {
	var clCoordinates: [CLLocationCoordinate2D] {
		coordinates.map { CLLocationCoordinate2D($0.coordinate) }
	}
}

// MARK: LiveTrack + Core Location
private extension LiveTrack {
    var clCoordinates: [CLLocationCoordinate2D] {
        coordinates.map { CLLocationCoordinate2D($0) }
    }
}


//  MARK: Coordinate + Core Lcoation
internal extension CLLocationCoordinate2D {
	init(_ coordinate: Coordinate) {
		self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
	}

	func distance(to other: CLLocationCoordinate2D) -> CLLocationDistance {
		MKMapPoint(self).distance(to: MKMapPoint(other))
	}
}
