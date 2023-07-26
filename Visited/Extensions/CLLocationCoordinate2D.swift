//
//  CLLocationCoordinate2D.swift
//  Visited
//
//  Created by Jack Finnis on 07/05/2023.
//

import MapKit

fileprivate let accuracy = 5

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude.equalTo(rhs.latitude, to: accuracy) && lhs.longitude.equalTo(rhs.longitude, to: accuracy)
    }
    
    var location: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }
}

extension CLLocationCoordinate2D: Identifiable {
    public var id: UUID { UUID() }
}
