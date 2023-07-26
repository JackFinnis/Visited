//
//  Array.swift
//  Visited
//
//  Created by Jack Finnis on 25/07/2023.
//

import Foundation

extension Array where Element: Equatable {
    mutating func removeAll(_ value: Element) {
        removeAll { $0 == value }
    }
}
