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
			let polygon = MKPolygon(coordinates: track.clCoordinates, count: track.coordinates.count)
			let rect = polygon.boundingMapRect
			let segments = graph.allSegments.filter { _, boundingBox in boundingBox.intersects(rect) }
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
private typealias BoundedSegment = (segment: Segment, box: MKMapRect)
private let epsilon: CLLocationDistance = 7

private extension Graph {
	var allSegments: [BoundedSegment] {
		guard !edges.isEmpty else { return [] }
		let mapPointsPerMeter = MKMapPointsPerMeterAtLatitude(edges.first!.key.latitude)
		let inset = mapPointsPerMeter * epsilon
		return edges.flatMap { source, destinations in
			destinations.map {
				let segment = (source, $0.coordinate)
				let rect1 = MKMapRect(origin: MKMapPoint(CLLocationCoordinate2D(segment.0)), size: .init())
				let rect2 = MKMapRect(origin: MKMapPoint(CLLocationCoordinate2D(segment.1)), size: .init())
				let rect = rect1.union(rect2).insetBy(dx: -inset, dy: -inset)
				return (segment, rect)
			}
		}
	}
}

//  MARK: Distance
public extension Graph {
	private typealias DistanceNode = (distance: CLLocationDistance, previous: Coordinate)
	func shortestPath(from: Coordinate, to: Coordinate) -> [Coordinate]? {
		assert(edges[from] != nil)
		assert(edges[to] != nil)
		var seen: Set<Coordinate> = []
		var distances: [Coordinate: DistanceNode] = [:]
		var queue: [(coordinate: Coordinate, distance: CLLocationDistance)] = [(from, 0)]
		while let (coordinate, distance) = queue.popLast() {
			guard !seen.contains(coordinate) else { continue }
			seen.insert(coordinate)

			for destination in edges[coordinate] ?? [] where !seen.contains(destination.coordinate) {
				let newDistance = distance + destination.distance
				if let existingDistance = distances[destination.coordinate]?.distance,
				   existingDistance < newDistance { continue }
				distances[destination.coordinate] = (newDistance, coordinate)
				queue.append((destination.coordinate, newDistance))
			}

			queue.sort { $0.distance > $1.distance }
		}

		guard var current = distances[to]?.previous else { return nil }
		var result = [to]
		while current != from {
			result.append(current)
			current = distances[current]!.previous
		}
		result.append(from)

		print(result)
		return result.reversed()
	}
}

private extension Array where Element == BoundedSegment {
	func closeEnough(to coordinate: Coordinate) -> Coordinate {
		let mapPoint = MKMapPoint(CLLocationCoordinate2D(coordinate))
		let filtered = filter { segment, box in box.contains(mapPoint) }
		guard !filtered.isEmpty else { return coordinate }
		if let (segment, distance) = filtered
			.map({ segment, box in (segment: segment, distance: coordinate.distance(to: segment)) })
			.min(by: { $0.distance < $1.distance }),
		   distance < epsilon {
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
