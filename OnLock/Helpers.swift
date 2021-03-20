//
//  Helpers.swift
//  OnLock
//
//  Created by James Valaitis on 11/03/2021.
//

import UIKit

public extension String {
	func remove(prefix: String) -> String {
		return String(dropFirst(prefix.count))
	}
}

public extension CGPoint {
	func distance(to other: CGPoint) -> CGFloat {
		(pow(other.x - x, 2) + pow(other.y - y, 2)).squareRoot()
	}
}

@discardableResult
func measure<A>(_ name: String = "", _ block: () -> A) -> A {
	let startTime = CACurrentMediaTime()
	let result = block()
	let timeElapsed = CACurrentMediaTime() - startTime
	print("Time: \(name) - \(timeElapsed)")
	return result
}

import CoreLocation
import MapKit

//  MARK: Coordinate + Core Location
public extension Coordinate {
	func distance(to other: Coordinate) -> CLLocationDistance {
		CLLocationCoordinate2D(self).distance(to: CLLocationCoordinate2D(other))
	}

	func distance(to lineSegment: (Coordinate, Coordinate)) -> CLLocationDistance {
		distance(to: closestPoint(on: lineSegment))
	}
}

internal extension CLLocationCoordinate2D {
	init(_ coordinate: Coordinate) {
		self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
	}
	func distance(to other: CLLocationCoordinate2D) -> CLLocationDistance {
		MKMapPoint(self).distance(to: MKMapPoint(other))
	}
}
