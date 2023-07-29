//
//  MKPointOfInterestCategory.swift
//  Visited
//
//  Created by Jack Finnis on 25/07/2023.
//

import MapKit
import SwiftUI

extension MKPointOfInterestCategory {
    static let defaultColor = Color.red
    static let defaultIcon = "mappin"
    
    var color: Color {
        switch self {
        case .bakery, .brewery, .cafe, .restaurant:
            return .orange
        case .foodMarket, .laundry, .store:
            return .yellow
        case .amusementPark, .aquarium, .movieTheater, .museum, .theater, .winery, .zoo, .nightlife:
            return .pink
        case .atm, .bank, .carRental, .police, .postOffice:
            return .gray
        case .airport, .gasStation, .parking, .publicTransport:
            return .blue
        case .fitnessCenter, .beach, .marina:
            return .cyan
        case .campground, .evCharger, .nationalPark, .park, .stadium:
            return .green
        case .fireStation, .hospital, .pharmacy:
            return .red
        case .hotel, .restroom:
            return .purple
        case .library, .school, .university:
            return .brown
        default:
            return Self.defaultColor
        }
    }
}

//public static let airport: MKPointOfInterestCategory
//public static let amusementPark: MKPointOfInterestCategory
//public static let aquarium: MKPointOfInterestCategory
//public static let atm: MKPointOfInterestCategory
//public static let bakery: MKPointOfInterestCategory
//public static let bank: MKPointOfInterestCategory
//public static let beach: MKPointOfInterestCategory
//public static let brewery: MKPointOfInterestCategory
//public static let cafe: MKPointOfInterestCategory
//public static let campground: MKPointOfInterestCategory
//public static let carRental: MKPointOfInterestCategory
//public static let evCharger: MKPointOfInterestCategory
//public static let fireStation: MKPointOfInterestCategory
//public static let fitnessCenter: MKPointOfInterestCategory
//public static let foodMarket: MKPointOfInterestCategory
//public static let gasStation: MKPointOfInterestCategory
//public static let hospital: MKPointOfInterestCategory
//public static let hotel: MKPointOfInterestCategory
//public static let laundry: MKPointOfInterestCategory
//public static let library: MKPointOfInterestCategory
//public static let marina: MKPointOfInterestCategory
//public static let movieTheater: MKPointOfInterestCategory
//public static let museum: MKPointOfInterestCategory
//public static let nationalPark: MKPointOfInterestCategory
//public static let nightlife: MKPointOfInterestCategory
//public static let park: MKPointOfInterestCategory
//public static let parking: MKPointOfInterestCategory
//public static let pharmacy: MKPointOfInterestCategory
//public static let police: MKPointOfInterestCategory
//public static let postOffice: MKPointOfInterestCategory
//public static let publicTransport: MKPointOfInterestCategory
//public static let restaurant: MKPointOfInterestCategory
//public static let restroom: MKPointOfInterestCategory
//public static let school: MKPointOfInterestCategory
//public static let stadium: MKPointOfInterestCategory
//public static let store: MKPointOfInterestCategory
//public static let theater: MKPointOfInterestCategory
//public static let university: MKPointOfInterestCategory
//public static let winery: MKPointOfInterestCategory
//public static let zoo: MKPointOfInterestCategory
