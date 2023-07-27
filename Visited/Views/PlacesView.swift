//
//  PlacesView.swift
//  Visited
//
//  Created by Jack Finnis on 25/07/2023.
//

import SwiftUI

struct PlacesView: View {
    @EnvironmentObject var vm: ViewModel
    @State var angle = Angle.zero
    
    var body: some View {
        VStack(spacing: 0) {
            if vm.places.isEmpty {
                BigLabel(systemName: "hand.tap", title: "No Places Yet", message: "Hold down on the map to save that place or search for an address.")
                    .centred()
                    .padding(.horizontal)
            } else {
                HStack(spacing: 15) {
                    Text(vm.filteredPlaces.count.formatted(singular: "Place") + (vm.isFiltering ? " Found" : ""))
                        .font(.headline)
                        .animation(.none, value: vm.filteredPlaces.count)
                        .onTapGesture {
                            vm.zoomToFilteredPlaces()
                            vm.ensureMapVisible()
                        }
                    Spacer()
                    Menu {
                        Picker("", selection: $vm.placeFilter.animation()) {
                            Text("No Filter")
                                .tag(nil as PlaceFilter?)
                            ForEach(PlaceFilter.allCases, id: \.self) { filter in
                                Label {
                                    Text(filter.name)
                                } icon: {
                                    if let icon = filter.icon {
                                        icon
                                    }
                                }
                                .tag(filter as PlaceFilter?)
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle\(vm.placeFilter == nil ? "" : ".fill")")
                            .font(.icon)
                    }
                    Menu {
                        Picker("", selection: $vm.sortBy.animation()) {
                            ForEach(PlaceSort.allCases, id: \.self) { sortBy in
                                if sortBy == vm.sortBy {
                                    Label(sortBy.rawValue, systemImage: vm.ascending ? "chevron.up" : "chevron.down")
                                } else {
                                    Text(sortBy.rawValue)
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.icon)
                            .rotationEffect(angle)
                            .rotation3DEffect(vm.ascending ? .zero : .radians(.pi), axis: (1, 0, 0))
                    }
                    .onChange(of: vm.sortBy) { _ in
                        withAnimation {
                            angle += .radians(.pi)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .frame(height: 35, alignment: .top)
                
                Divider()
                    .padding(.leading, 20)
                if vm.filteredPlaces.isEmpty {
                    Text("No Places Found")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .centred()
                } else {
                    List {
                        ListBuffer(isPresented: vm.filteredPlaces.isEmpty)
                        ForEach(vm.filteredPlaces) { place in
                            PlaceRow(place: place)
                                .listRowSeparator(place == vm.filteredPlaces.first ? .hidden : .automatic, edges: .top)
                        }
                    }
                    .listStyle(.plain)
                }
            }
        }
        .animation(.default, value: vm.filteredPlaces)
        .transition(.move(edge: .leading))
    }
}

struct PlacesView_Previews: PreviewProvider {
    static var previews: some View {
        PlacesView()
    }
}
