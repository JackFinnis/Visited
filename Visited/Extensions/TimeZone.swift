//
//  TimeZone.swift
//  Visited
//
//  Created by Jack Finnis on 26/07/2023.
//

import Foundation

extension TimeZone {
    var currentTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = self
        return formatter.string(from: .now)
    }
}

extension TimeZone: Comparable {
    public static func < (lhs: TimeZone, rhs: TimeZone) -> Bool {
        lhs.secondsFromGMT() < rhs.secondsFromGMT()
    }
}
