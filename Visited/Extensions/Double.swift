//
//  Double.swift
//  Visited
//
//  Created by Jack Finnis on 25/07/2023.
//

import Foundation

extension Double {
    func equalTo(_ other: Double, to places: Int) -> Bool {
        rounded(to: places) == other.rounded(to: places)
    }
    
    func rounded(to places: Int) -> Double {
        let shift = pow(10, Double(places))
        return (self * shift).rounded() / shift
    }
}

