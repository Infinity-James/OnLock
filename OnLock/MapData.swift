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
internal final class MapData: ObservableObject {
	@Published private var tracks: [MapTrack] = []
	public var graph: Graph?
	internal var boundingRect: MKMapRect {
		tracks
			.map { $0.polygon.boundingMapRect }
			.reduce(MKMapRect.null) { $0.union($1) }
	}
	private var disposables = Set<AnyCancellable>()

	init() {
		$tracks
			.sink { [unowned self] tracks in graph = .build(from: tracks.map(\.track)) }
			.store(in: &disposables)
	}

	internal func load() {
		DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
			let loadedTracks = Track.loadTestData()
//				.filter { $0.color == .pink }
				.map { track in MapTrack(track: track, polygon: MKPolygon(coordinates: track.clCoordinates, count: track.coordinates.count)) }

			DispatchQueue.main.async {
				print("Loaded: \(loadedTracks.count)")
				tracks = loadedTracks
			}
		}
	}

	internal func addPolygons(to map: MKMapView) {
		map.addOverlays(tracks.map { $0.polygon })
	}

	internal func track(for polygon: MKPolygon) -> Track? {
		tracks.first(where: { $0.polygon == polygon })?.track
	}

	private var tappedPoints: [Coordinate] = []

	internal func tapped(_ coordinate: CLLocationCoordinate2D) -> [Coordinate]? {
		guard let graph = graph else { return nil }
		let coord = Coordinate(latitude: coordinate.latitude, longitude: coordinate.longitude)
		let trackPoint = graph.edges.keys
			.map { (point: $0, distance: $0.distance(to: coord)) }
			.min { c1, c2 in c1.distance < c2.distance }
		guard let closest = trackPoint?.point else { return nil }
		tappedPoints.append(closest)

		guard tappedPoints.count >= 2 else { return nil }

		return graph.shortestPath(from: tappedPoints[tappedPoints.endIndex - 2], to: tappedPoints[tappedPoints.endIndex - 1])
	}
}

//  MARK: Map Track
private struct MapTrack: Hashable {
	let track: Track
	let polygon: MKPolygon
}

//  MARK: Track + Core Location
internal extension Track {
	var clCoordinates: [CLLocationCoordinate2D] {
		coordinates.map { CLLocationCoordinate2D($0.coordinate) }
	}
}
