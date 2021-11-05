//
//  TrackReader.swift
//  OnLock
//
//  Created by James Valaitis on 11/03/2021.
//

import Foundation

//  MARK: Track Reader
final class TrackReader: NSObject, XMLParserDelegate {
	var inTrk = false
	var points: [CoordinateWithElevation] = []
	var pending: (lat: Double, lon: Double)?
	var elementContents: String = ""
	var name = ""

	init?(url: URL) {
		guard let parser = XMLParser(contentsOf: url) else { return nil }
		super.init()
		parser.delegate = self
		guard parser.parse() else { return nil }
	}

	func parser(_ parser: XMLParser, foundCharacters string: String) {
		elementContents += string
	}

	func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
		guard inTrk else {
			inTrk = elementName == "trk"
			return
		}
		if elementName == "trkpt" {
			guard let latStr = attributeDict["lat"], let lat = Double(latStr),
				let lonStr = attributeDict["lon"], let lon = Double(lonStr) else { return }
			pending = (lat: lat, lon: lon)
		}
	}

	func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		defer { elementContents = "" }
		var trimmed: String { return elementContents.trimmingCharacters(in: .whitespacesAndNewlines) }
		if elementName == "trk" {
			inTrk = false
		} else if elementName == "ele" {
			guard let p = pending, let ele = Double(trimmed) else { return }
			points.append(CoordinateWithElevation(coordinate: .init(latitude: p.lat, longitude: p.lon), elevation: ele))
		} else if elementName == "name" && inTrk {
			name = trimmed.remove(prefix: "Laufpark Stechlin - Wabe ")
		}
	}
}

