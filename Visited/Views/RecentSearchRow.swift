//
//  RecentSearchRow.swift
//  Visited
//
//  Created by Jack Finnis on 25/07/2023.
//

import SwiftUI

struct RecentSearchRow: View {
    @EnvironmentObject var vm: ViewModel
    
    let string: String
    
    var body: some View {
        Button {
            vm.searchMaps(.string(string))
        } label: {
            HStack(spacing: 0) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .padding(.trailing, 10)
                Text(string)
                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .listRowBackground(Color.clear)
        .swipeActions {
            Button("Delete", role: .destructive) {
                vm.removeRecentSearch(string)
            }
        }
    }
}
