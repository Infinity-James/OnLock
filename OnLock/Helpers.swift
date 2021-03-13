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
