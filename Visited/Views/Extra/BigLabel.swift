//
//  BigLabel.swift
//  Visited
//
//  Created by Jack Finnis on 26/07/2023.
//

import SwiftUI

struct BigLabel: View {
    let systemName: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: systemName)
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text(title)
                .font(.title3.bold())
            Text(message)
                .font(.subheadline)
                .padding(.horizontal)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .fixedSize(horizontal: false, vertical: true)
    }
}
