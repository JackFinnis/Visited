//
//  String.swift
//  Visited
//
//  Created by Jack Finnis on 06/05/2023.
//

import Foundation

extension String {
    var replaceSpaces: String {
        replacingOccurrences(of: " ", with: "%20")
    }
    
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
