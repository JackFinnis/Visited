//
//  PlaceRow.swift
//  Visited
//
//  Created by Jack Finnis on 25/07/2023.
//

import SwiftUI

struct PlaceRow: View {
    @EnvironmentObject var vm: ViewModel
    
    let place: Place
    
    var body: some View {
        Button {
            vm.selectAnnotation(place)
        } label: {
            HStack(spacing: 0) {
                Image(systemName: "mappin.circle.fill")
                    .font(.title)
                    .foregroundStyle(Color.white, place.type.color)
                    .padding(.trailing, 10)
                VStack(alignment: .leading) {
                    Text(place.title ?? "")
                    Text(place.subtitle ?? "")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .listRowBackground(Color.clear)
        .lineLimit(1)
        .contextMenu {
            Button {
                vm.openInMaps(place)
            } label: {
                Label("Open in Maps", systemImage: "map")
            }
            Button {
                vm.selectedPlace = place
            } label: {
                Label("Edit Place", systemImage: "pencil")
            }
            Button {
                vm.sharePlace(place)
            } label: {
                Label("Share...", systemImage: "square.and.arrow.up")
            }
        }
    }
}
