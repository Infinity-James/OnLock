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
	public var graph: Graph { .build(from: tracks.map(\.track)) }
	internal var boundingRect: MKMapRect {
		tracks
			.map { $0.polygon.boundingMapRect }
			.reduce(MKMapRect.null) { $0.union($1) }
	}
    private let locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = 15
        return locationManager
    }()
    private let minimumLiveTrackDistance: Double = 5

	internal func load() {
		DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
			let loadedTracks = Track.loadTestData()
				.filter { $0.color == .pink }
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
        
        let line = MKPolyline(coordinates: liveMapTrack.coordinates, count: liveMapTrack.coordinates.count)
        map.addOverlay(line)
        
        map.setVisibleMapRect(line.boundingMapRect,
                              edgePadding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10),
                              animated: true)
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
    
    internal func checkForConnection(liveMapTrack: LiveMapTrack) {
        guard let firstCoordinate = liveMapTrack.coordinates.first,
              let lastCoordinate = liveMapTrack.coordinates.last,
              liveMapTrack.coordinates.count > 3  else { return }
        
        let distance = firstCoordinate.distance(to: lastCoordinate)
        if distance < minimumLiveTrackDistance {
            self.liveMapTrack = nil
            let mapTrack = MapTrack(coordinates: liveMapTrack.coordinates)
            tracks.append(mapTrack)
        }
        
    }
}
//  MARK: Core Location Manager Delegate
extension MapData: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last,
              newLocation.horizontalAccuracy < manager.desiredAccuracy else {
            return
        }
        
        guard liveMapTrack != nil else {
            liveMapTrack = LiveMapTrack(coordinates: [newLocation.coordinate])
            return
        }
        
        guard let liveMapTrack = liveMapTrack,
              let previousCoordinate = liveMapTrack.coordinates.last, 
              newLocation.coordinate.distance(to: previousCoordinate) > minimumLiveTrackDistance else {
            return
        }
        
        self.liveMapTrack!.coordinates.append(newLocation.coordinate)
        checkForConnection(liveMapTrack: liveMapTrack)
    }
}


//  MARK: Map Track
private struct MapTrack: Hashable {
	let track: Track
	let polygon: MKPolygon
}

private extension MapTrack {
    init(coordinates: [CLLocationCoordinate2D]) {
        let coordinatesWithElevation: [CoordinateWithElevation] = coordinates.map {
            let coordinate = Coordinate(latitude: Double($0.latitude), longitude: Double($0.longitude))
            return CoordinateWithElevation(coordinate: coordinate, elevation: 0.0)
        }
        track = Track(coordinates: coordinatesWithElevation, color: .lightPink, number: coordinates.count, name: "Live Track")
        polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
    }
}

// MARK: Track + Core Location
private extension Track {
	var clCoordinates: [CLLocationCoordinate2D] {
		coordinates.map { CLLocationCoordinate2D($0.coordinate) }
	}
}
