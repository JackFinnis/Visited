//
//  String.swift
//  Visited
//
//  Created by Jack Finnis on 06/05/2023.
//

import Foundation

extension String {
    var urlEncoded: String? {
        addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
    
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
