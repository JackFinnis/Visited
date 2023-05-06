//
//  PlaceView.swift
//  Visited
//
//  Created by Jack Finnis on 06/05/2023.
//

import SwiftUI
import MapKit

struct PlaceView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: ViewModel
    @State var type = PlaceType.visited
    @State var name = ""
    @State var region = MKCoordinateRegion()
    @FocusState var focused: Bool
    
    var new: Bool { vm.selectedPlace == nil }
    
    var body: some View {
        NavigationView {
            Form {
                Section {} header: {
                    ZStack {
                        Map(coordinateRegion: $region)
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                            .font(.title2)
                    }
                    .aspectRatio(1, contentMode: .fit)
                    .continuousRadius(10)
                }
                
                Section {
                    TextField("Name", text: $name)
                        .focused($focused)
                } header: {
                    Picker("", selection: $type) {
                        ForEach(PlaceType.allCases, id: \.self) { type in
                            Text(type.name)
                        }
                    }
                    .pickerStyle(.segmented)
                    .textCase(nil)
                    .padding(.bottom, 10)
                }
            }
            .onAppear {
                type = vm.selectedPlace?.type ?? type
                name = vm.selectedPlace?.name ?? name
                region.center = vm.selectedPlace?.coordinate ?? vm.selectedCoord ?? vm.mapView?.centerCoordinate ?? .init()
            }
            .navigationTitle(new ? "New Pin" : "Edit Pin")
            .navigationBarTitleDisplayMode(.inline)
            .animation(.default, value: focused)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: savePin) {
                        Text(new ? "Add" : "Save")
                            .bold()
                    }
                    .disabled(name.trimmed.isEmpty)
                }
            }
        }
    }
    
    func savePin() {
        let place: Place
        if let selectedPlace = vm.selectedPlace {
            place = selectedPlace
        } else {
            place = Place(context: vm.container.viewContext)
            vm.places.append(place)
        }
        place.name = name
        place.type = type
        place.lat = region.center.latitude
        place.long = region.center.longitude
        vm.save()
        vm.mapView?.removeAnnotation(place)
        vm.mapView?.addAnnotation(place)
        Haptics.tap()
        dismiss()
    }
}

struct PlaceView_Previews: PreviewProvider {
    static var previews: some View {
        Text("")
            .sheet(isPresented: .constant(true)) {
                PlaceView()
                    .environmentObject(ViewModel())
            }
    }
}
