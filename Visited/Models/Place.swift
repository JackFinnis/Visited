//
//  Place.swift
//  Visited
//
//  Created by Jack Finnis on 06/05/2023.
//

import SwiftUI
import MapKit
import CoreData

@objc(Place)
class Place: NSManagedObject {
    @NSManaged var name: String
    @NSManaged var type: PlaceType
    @NSManaged var lat: Double
    @NSManaged var long: Double
}

extension Place: MKAnnotation {
    var coordinate: CLLocationCoordinate2D { CLLocationCoordinate2DMake(lat, long) }
    var title: String? { name }
    var subtitle: String? { type.name }
}

@objc
enum PlaceType: Int16, CaseIterable {
    case visited
    case tovisit
    
    var name: String {
        switch self {
        case .visited:
            return "Visited"
        case .tovisit:
            return "Wishlist"
        }
    }
    
    var color: Color {
        switch self {
        case .visited:
            return .red
        case .tovisit:
            return .accentColor
        }
    }
}
