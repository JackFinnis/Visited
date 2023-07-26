//
//  SearchView.swift
//  Trails
//
//  Created by Jack Finnis on 19/04/2023.
//

import SwiftUI
import MapKit

struct SearchView: View {
    @EnvironmentObject var vm: ViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            if vm.searchLoading {
                ProgressView()
                    .centred()
            } else if vm.isEditing {
                if vm.searchText.isNotEmpty {
                    Divider()
                        .padding(.leading, 20)
                    List {
                        ListBuffer(isPresented: vm.searchCompletions.isEmpty)
                        ForEach(vm.searchCompletions, id: \.self) { completion in
                            CompletionRow(completion: completion)
                                .listRowSeparator(completion == vm.searchCompletions.first ? .hidden : .automatic, edges: .top)
                        }
                    }
                } else if vm.recentSearches.isNotEmpty {
                    HStack {
                        Text("Recents")
                            .font(.headline)
                        Spacer()
                        Button("Clear") {
                            vm.recentSearches = []
                        }
                    }
                    .padding(.horizontal, 20)
                    .frame(height: 35, alignment: .top)
                    
                    Divider()
                        .padding(.leading, 20)
                    List {
                        ListBuffer(isPresented: vm.recentSearches.isEmpty)
                        ForEach(vm.recentSearches.reversed(), id: \.self) { string in
                            RecentSearchRow(string: string)
                                .listRowSeparator(string == vm.recentSearches.last ? .hidden : .automatic, edges: .top)
                        }
                    }
                    .listStyle(.plain)
                }
            } else if vm.searchResults.isEmpty {
                Text("No Results")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .centred()
            } else {
                Divider()
                    .padding(.leading, 20)
                List {
                    ListBuffer(isPresented: vm.searchResults.isEmpty)
                    ForEach(vm.searchResults, id: \.self) { result in
                        SearchResultRow(result: result)
                            .listRowSeparator(result == vm.searchResults.first ? .hidden : .automatic, edges: .top)
                    }
                }
            }
        }
        .lineLimit(1)
        .listStyle(.plain)
        .transition(.move(edge: .trailing))
        .animation(.default, value: vm.recentSearches)
    }
}
