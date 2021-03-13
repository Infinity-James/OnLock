//
//  Track.swift
//  OnLock
//
//  Created by James Valaitis on 11/03/2021.
//

//  MARK: Track
public struct Track: Decodable, Equatable, Hashable {
	public let coordinates: [CoordinateWithElevation]
	public let color: Color
	public let number: Int
	public let name: String

	public var numbers: String {
		let components = name.split(separator: " ")
		guard !components.isEmpty else { return "" }

		func simplify<S: StringProtocol>(_ numbers: [S]) -> String {
			if numbers.count == 1 { return String(numbers[0]) }
			return String("\(numbers[0])-\(numbers.last!)")
		}

		return simplify(components.last!.split(separator: "/"))
	}

	public enum Color: Int, Decodable, Hashable {
		case red
		case turquoise
		case brightGreen
		case violet
		case purple
		case green
		case beige
		case blue
		case brown
		case yellow
		case gray
		case lightBlue
		case lightBrown
		case orange
		case pink
		case lightPink
	}
}


