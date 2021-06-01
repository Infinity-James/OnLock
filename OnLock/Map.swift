//
//  Map.swift
//  OnLock
//
//  Created by James Valaitis on 11/03/2021.
//

import MapKit
import SwiftUI
import UIKit

//  MARK: Map
public struct Map: UIViewControllerRepresentable {
	@ObservedObject private var data = MapData()

	public func makeUIViewController(context: Context) -> MapView {
		data.load()

		return MapView()
	}

	public func updateUIViewController(_ map: MapView, context: Context) {
		map.configure(with: data)
	}
}

//  MARK: UIKit Map
public final class MapView: UIViewController {
	private let map = MKMapView()
	private var data: MapData?

	public override func viewDidLoad() {
		super.viewDidLoad()
		map.delegate = self
		view.addSubview(map)
		map.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			map.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			map.topAnchor.constraint(equalTo: view.topAnchor),
			map.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			map.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
		map.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
	}

	@objc private func tapped(_ recognizer: UITapGestureRecognizer) {
		guard let data = data else { return }
		let location = recognizer.location(in: map)
		let tapCoordinate = map.convert(location, toCoordinateFrom: map)
		guard let (track, closestPoint) = data.closest(to: tapCoordinate) else { return }

		let closestInPoints = map.convert(closestPoint, toPointTo: map)
		if closestInPoints.distance(to: location) < (44 / 2) {
			let annotation = MKPointAnnotation()
			annotation.coordinate = closestPoint
			annotation.title = track.name
			map.addAnnotation(annotation)
		}
	}

	func configure(with data: MapData) {
		self.data = data
		data.addPolygons(to: map)
        data.addPolyLines(to: map)
//		map.setVisibleMapRect(data.boundingRect,
//							  edgePadding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10),
//							  animated: true)
//		let graph = measure("Build graph") { data.graph }
//  		render(graph)
	}

	func render(_ graph: Graph) {
		guard let startingPoint = graph.edges.keys.randomElement() else { return }
		let steps = graph.debug_connectedVertices(from: startingPoint)

		func draw(_ remainingSteps: ArraySlice<[(Coordinate, Coordinate)]>) {
			guard let step = remainingSteps.first else { return }
			for edge in step {
				map.addOverlay(MKPolyline(coordinates: [CLLocationCoordinate2D(edge.0), CLLocationCoordinate2D(edge.1)], count: 2))
			}
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
				draw(remainingSteps.dropFirst())
			}
		}

		draw(steps[...])
	}
}

//  MARK: MKMapViewDelegate
extension MapView: MKMapViewDelegate {
	public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		guard let data = data else { return MKOverlayRenderer(overlay: overlay) }
		if let polygon = overlay as? MKPolygon, let track = data.track(for: polygon) {
			let renderer = MKPolygonRenderer(overlay: polygon)
			renderer.lineWidth = 1
			renderer.strokeColor = track.color.uiColor
			renderer.fillColor = track.color.uiColor.withAlphaComponent(0.2)
			return renderer
		} else if let line = overlay as? MKPolyline {
			let renderer = MKPolylineRenderer(polyline: line)
			renderer.strokeColor = .black
			renderer.lineWidth = 4
			return renderer
		} else { return MKOverlayRenderer(overlay: overlay) }

	}
}

//  MARK: Track Color -> UIColor
private extension Track.Color {
	var uiColor: UIColor {
		switch self {
		case .red:
			return UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
		case .turquoise:
			return UIColor(red: 0/255, green: 159/255, blue: 159/255, alpha: 1)
		case .brightGreen:
			return UIColor(red: 104/255, green: 195/255, blue: 12/255, alpha: 1)
		case .violet:
			return UIColor(red: 174/255, green: 165/255, blue: 213/255, alpha: 1)
		case .purple:
			return UIColor(red: 135/255, green: 27/255, blue: 138/255, alpha: 1)
		case .green:
			return UIColor(red: 0/255, green: 132/255, blue: 70/255, alpha: 1)
		case .beige:
			return UIColor(red: 227/255, green: 177/255, blue: 151/255, alpha: 1)
		case .blue:
			return UIColor(red: 0/255, green: 92/255, blue: 181/255, alpha: 1)
		case .brown:
			return UIColor(red: 126/255, green: 50/255, blue: 55/255, alpha: 1)
		case .yellow:
			return UIColor(red: 255/255, green: 244/255, blue: 0/255, alpha: 1)
		case .gray:
			return UIColor(red: 174/255, green: 165/255, blue: 213/255, alpha: 1)
		case .lightBlue:
			return UIColor(red: 0/255, green: 166/255, blue: 198/255, alpha: 1)
		case .lightBrown:
			return UIColor(red: 190/255, green: 135/255, blue: 90/255, alpha: 1)
		case .orange:
			return UIColor(red: 255/255, green: 122/255, blue: 36/255, alpha: 1)
		case .pink:
			return UIColor(red: 255/255, green: 0/255, blue: 94/255, alpha: 1)
		case .lightPink:
			return UIColor(red: 255/255, green: 122/255, blue: 183/255, alpha: 1)
		}
	}
}

