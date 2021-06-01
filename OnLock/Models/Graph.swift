//
//  Graph.swift
//  OnLock
//
//  Created by James Valaitis on 17/03/2021.
//

import CoreLocation

//  MARK: Graph
public struct Graph {
	private(set) var edges: [Coordinate: [Destination]] = [:]

	mutating func addEdge(from: Coordinate, to: Coordinate) {
		let distance = from.distance(to: to)
		edges[from, default: []].append(Destination(coordinate: to, distance: distance))
	}
}

//  MARK: Destination
public extension Graph {
	struct Destination {
		var coordinate: Coordinate
		var distance: CLLocationDistance
	}
}

//  MARK: CLLocationCoordinate2D + Vector2D
//	While not a Euclidian space, it works well enough at short distances. So shut up, Lewis.
extension Coordinate: Vector2D {
	public var x: Double { longitude }
	public var y: Double { latitude }
	public init(x: Double, y: Double) {
		self.init(latitude: y, longitude: x)
	}
}

//  MARK: Graph Building
public extension Graph {
	static func build(from tracks: [Track]) -> Graph {
		var graph = Graph()
		for track in tracks {
			let segments = graph.allSegments
			for (from, to) in zip(track.coordinates, track.coordinates.dropFirst() + [track.coordinates[0]]) {
				graph.addEdge(from: segments.closeEnough(to: from.coordinate),
							  to: segments.closeEnough(to: to.coordinate))
			}
		}
		return graph
	}
}

import MapKit

private typealias Segment = (Coordinate, Coordinate)
private typealias SegmentRegion = (segment: Segment, box: MKMapRect)

private extension Graph {
	var allSegments: [SegmentRegion] {
		edges.flatMap { source, destinations in
			destinations.map {
				let segment = (source, $0.coordinate)
				let rect1 = MKMapRect(origin: MKMapPoint(CLLocationCoordinate2D(segment.0)), size: .init())
				let rect2 = MKMapRect(origin: MKMapPoint(CLLocationCoordinate2D(segment.1)), size: .init())
				let rect = rect1.union(rect2)
				return (segment, rect)
			}
		}
	}
}

private extension Array where Element == SegmentRegion {
	func closeEnough(to coordinate: Coordinate) -> Coordinate {
		guard !isEmpty else { return coordinate }
		let epsilon: CLLocationDistance = 7
        let (segment, distance) = map { segmentRegion in (segment: segmentRegion.segment, distance: coordinate.distance(to: segmentRegion.segment)) }
			.min { $0.distance < $1.distance }!
		if distance < epsilon {
			return segment.0
		} else { return coordinate }
	}
}

//  MARK: Debug
extension Graph {
	func debug_connectedVertices(from: Coordinate) -> [[(Coordinate, Coordinate)]] {
		var result: [[(Coordinate, Coordinate)]] = [[]]
		var seen: Set<Coordinate> = []

		var sourcePoints = [from]
		while !sourcePoints.isEmpty {
			var newSourcePoints: [Coordinate] = []
			for source in sourcePoints {
				seen.insert(source)
				for edge in edges[source] ?? [] {
					result[result.endIndex - 1].append((source, edge.coordinate))
					newSourcePoints.append(edge.coordinate)
				}
			}
			result.append([])
			sourcePoints = newSourcePoints.filter { !seen.contains($0) }
		}
		return result
	}
}
