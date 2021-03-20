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
	public var graph: Graph { .build(from: tracks.map(\.track)) }
	internal var boundingRect: MKMapRect {
		tracks
			.map { $0.polygon.boundingMapRect }
			.reduce(MKMapRect.null) { $0.union($1) }
	}

	internal func load() {
		DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
			let loadedTracks = Track.loadTestData()
//				.filter { $0.color == .pink }
				.map { track in MapTrack(track: track, polygon: MKPolygon(coordinates: track.clCoordinates, count: track.coordinates.count)) }

			DispatchQueue.main.async { tracks = loadedTracks }
		}
	}

	internal func addPolygons(to map: MKMapView) {
		map.addOverlays(tracks.map { $0.polygon })
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
