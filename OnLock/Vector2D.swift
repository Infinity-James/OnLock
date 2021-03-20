//
//  Vector2D.swift
//  OnLock
//
//  Created by James Valaitis on 17/03/2021.
//

import Foundation
import UIKit

//  MARK: Vector 2D
public protocol Vector2D {
	associatedtype Component: Numeric
	var x: Component { get }
	var y: Component { get }
	init(x: Component, y: Component)
}

//  MARK: Vector Maths
public extension Vector2D {
	static func -(lhs: Self, rhs: Self) -> Self {
		.init(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
	}

	static func +(lhs: Self, rhs: Self) -> Self {
		.init(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
	}

	static func *(lhs: Component, rhs: Self) -> Self {
		.init(x: lhs * rhs.x, y: lhs * rhs.y)
	}

	func dot(_ other: Self) -> Component {
		(x * other.x) + (y * other.y)
	}

	func closestPoint(on lineSegment: (s1: Self, s2: Self)) -> Self where Component: FloatingPoint {
		let normalisedS2 = lineSegment.s2 - lineSegment.s1
		let p = self - lineSegment.s1
		let lambda = normalisedS2.dot(p) / normalisedS2.dot(normalisedS2)
		let clamped = min(1, max(0, lambda))
		return lineSegment.s1 + clamped * normalisedS2
	}
}

extension CGPoint: Vector2D { }
