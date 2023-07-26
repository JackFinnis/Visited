//
//  CompletionRow.swift
//  Visited
//
//  Created by Jack Finnis on 25/07/2023.
//

import SwiftUI
import MapKit

struct CompletionRow: View {
    @EnvironmentObject var vm: ViewModel
    
    let completion: MKLocalSearchCompletion
    
    var body: some View {
        Button {
            vm.searchMaps(.completion(completion))
        } label: {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(completion.title)
                        .font(.headline)
                    Text(completion.subtitle + " ")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .listRowBackground(Color.clear)
    }
}
