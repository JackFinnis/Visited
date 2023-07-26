//
//  Search.swift
//  Visited
//
//  Created by Jack Finnis on 25/07/2023.
//

import MapKit

enum Search {
    case string(String)
    case completion(MKLocalSearchCompletion)
}

enum SearchScope: String, CaseIterable {
    case Places
    case Maps
}
