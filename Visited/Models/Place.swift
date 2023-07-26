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
class Place: NSManagedObject, Identifiable {
    @NSManaged var name: String
    @NSManaged var type: PlaceType
    @NSManaged var lat: Double
    @NSManaged var long: Double
    @NSManaged var placemark: CLPlacemark
}

extension Place: MKAnnotation {
    var coordinate: CLLocationCoordinate2D { CLLocationCoordinate2DMake(lat, long) }
    var title: String? { name }
    var subtitle: String? { getSubtitle([
        placemark.isoCountryCode ?? "",
        placemark.timeZone?.currentTime ?? "",
        formattedDistance,
        placemark.locality ?? ""
    ])}
}

@objc
enum PlaceType: Int16, CaseIterable {
    case visited
    case tovisit
    case lived
    
    static let allCases: [PlaceType] = [.visited, .lived, .tovisit]
    
    var name: String {
        switch self {
        case .visited:
            return "Visited"
        case .tovisit:
            return "Bucket List"
        case .lived:
            return "Lived"
        }
    }
    
    var color: Color {
        switch self {
        case .visited:
            return .red
        case .tovisit:
            return Color(.link)
        case .lived:
            return .orange
        }
    }
}

enum PlaceFilter: CaseIterable, Hashable {
    case type(PlaceType)
    
    static let allCases: [PlaceFilter] = PlaceType.allCases.map { PlaceFilter.type($0) }
    
    var name: String {
        switch self {
        case .type(let type):
            return type.name
        }
    }
    
    var icon: Image? {
        switch self {
        case .type(let type):
            let config = UIImage.SymbolConfiguration(paletteColors: [.white, .init(type.color)])
            let uiImage = UIImage(systemName: "mappin.circle.fill", withConfiguration: config)!
            return Image(uiImage: uiImage)
        }
    }
}

enum PlaceSort: String, CaseIterable, Equatable, Codable {
    case Name
    case Time
    case Distance
    case Country
}

//@NSCopying open var location: CLLocation? { get }
//@NSCopying open var region: CLRegion? { get }
//open var timeZone: TimeZone? { get }
//open var addressDictionary: [AnyHashable : Any]? { get }
//open var name: String? { get } // eg. Apple Inc.
//open var thoroughfare: String? { get } // street name, eg. Infinite Loop
//open var subThoroughfare: String? { get } // eg. 1
//open var locality: String? { get } // city, eg. Cupertino
//open var subLocality: String? { get } // neighborhood, common name, eg. Mission District
//open var administrativeArea: String? { get } // state, eg. CA
//open var subAdministrativeArea: String? { get } // county, eg. Santa Clara
//open var postalCode: String? { get } // zip code, eg. 95014
//open var isoCountryCode: String? { get } // eg. US
//open var country: String? { get } // eg. United States
//open var inlandWater: String? { get } // eg. Lake Tahoe
//open var ocean: String? { get } // eg. Pacific Ocean
//open var areasOfInterest: [String]? { get } // eg. Golden Gate Park
//open var postalAddress: CNPostalAddress? { get }
