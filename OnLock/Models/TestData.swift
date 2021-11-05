//
//  TestData.swift
//  OnLock
//
//  Created by James Valaitis on 11/03/2021.
//

import Foundation

//  MARK: Track + Test Data
internal extension Track {
	static func loadTestData() -> [Track] {
		let definitions: [(ColorCategory, Int)] = [
			(.red, 4),
			(.turquoise, 5),
			(.brightGreen, 7),
			(.beige, 2),
			(.green, 4),
			(.purple, 3),
			(.violet, 4),
			(.blue, 3),
			(.brown, 4),
			(.yellow, 4),
			(.gray, 0),
			(.lightBlue, 4),
			(.lightBrown, 5),
			(.orange, 0),
			(.pink, 4),
			(.lightPink, 6)
		]
		var allTracks: [[Track]] = []
		allTracks = definitions.map { (color, count) in
			let begin = count == 0 ? 0 : 1
			let trackNames: [(Int, String)] = (begin...count).map { ($0, "wabe \(color.name)-strecke \($0)") }
			return trackNames.map { numberAndName -> Track in
				let url = Bundle.main.url(forResource: numberAndName.1, withExtension: "gpx")!
				let reader = TrackReader(url: url)!
				return Track(coordinates: reader.points, color: color.color, number: numberAndName.0, name: reader.name)
			}
		}
		return Array(allTracks.joined())
	}

}

private enum ColorCategory: Int, Codable, Equatable, Hashable {
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
	
	var name: String {
		switch self {
		case .red: return "rot"
		case .turquoise: return "tuerkis"
		case .brightGreen: return "hellgruen"
		case .beige: return "beige"
		case .green: return "gruen"
		case .purple: return "lila"
		case .violet: return "violett"
		case .blue: return "blau"
		case .brown: return "braun"
		case .yellow: return "gelb"
		case .gray: return "grau"
		case .lightBlue: return "hellblau"
		case .lightBrown: return "hellbraun"
		case .orange: return "orange"
		case .pink: return "pink"
		case .lightPink: return "rosa"
		}
	}

	var color: Track.Color {
		switch self {
		case .red:
			return .red
		case .turquoise:
			return .turquoise
		case .brightGreen:
			return .brightGreen
		case .violet:
			return .violet
		case .purple:
			return .purple
		case .green:
			return .green
		case .beige:
			return .beige
		case .blue:
			return .blue
		case .brown:
			return .brown
		case .yellow:
			return .yellow
		case .gray:
			return .gray
		case .lightBlue:
			return .lightBlue
		case .lightBrown:
			return .lightBrown
		case .orange:
			return .orange
		case .pink:
			return .pink
		case .lightPink:
			return .lightPink
		}
	}
}
