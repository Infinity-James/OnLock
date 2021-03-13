//
//  Coordinate.swift
//  OnLock
//
//  Created by James Valaitis on 11/03/2021.
//

import Foundation

//  MARK: Coordinate
public struct Coordinate: Decodable, Equatable, Hashable {
	public let latitude: Double
	public let longitude: Double
}

//  MARK: Coordinate with Elevation
public struct CoordinateWithElevation: Decodable, Equatable, Hashable {
	public let coordinate: Coordinate
	public let elevation: Double
}
