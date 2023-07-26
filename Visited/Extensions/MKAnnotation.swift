//
//  MKAnnotation.swift
//  Visited
//
//  Created by Jack Finnis on 26/07/2023.
//

import MapKit

extension MKAnnotation {
    var distance: Double? {
        guard let user = CLLocationManager.shared.location else { return nil }
        return coordinate.location.distance(from: user)
    }
    
    var formattedDistance: String {
        guard let distance else { return "" }
        return Measurement(value: distance, unit: UnitLength.meters).formatted()
    }
    
    func getSubtitle(_ parts: [String]) -> String {
        parts.filter(\.isNotEmpty).joined(separator: " • ")
    }
}
