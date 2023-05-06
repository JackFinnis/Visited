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
    var valid: Bool { name.trimmed.isNotEmpty }
    
    var body: some View {
        NavigationView {
            Form {
                Section {} header: {
                    ZStack {
                        Map(coordinateRegion: $region, showsUserLocation: true)
                        Image(systemName: "circle.fill")
                            .foregroundColor(type.color)
                            .font(.title3)
                            .addShadow()
                            .allowsHitTesting(false)
                    }
                    .aspectRatio(1, contentMode: .fit)
                    .continuousRadius(10)
                }
                
                Section {
                    TextField("Name", text: $name)
                        .focused($focused)
                        .submitLabel(.done)
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
                
                if let place = vm.selectedPlace {
                    Section {
                        Button("Delete") {
                            vm.deletePlace(place)
                            dismiss()
                        }
                        .foregroundColor(.red)
                        .horizontallyCentred()
                    }
                }
            }
            .onAppear {
                type = vm.selectedPlace?.type ?? type
                name = vm.selectedPlace?.name ?? name
                region.center = vm.selectedPlace?.coordinate ?? vm.selectedCoord ?? vm.mapView?.centerCoordinate ?? .init()
                let spanDelta = 0.002
                region.span.latitudeDelta = spanDelta
                region.span.longitudeDelta = spanDelta
            }
            .navigationTitle(new ? "New Pin" : "Edit Pin")
            .navigationBarTitleDisplayMode(.inline)
            .animation(.default, value: focused)
            .safeAreaInset(edge: .bottom) {
                if new && !focused {
                    Button(action: savePin) {
                        Text("Add Pin")
                            .bigButton()
                    }
                    .padding()
                    .disabled(!valid)
                    .textCase(nil)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    if !new {
                        Button("Save", action: savePin)
                            .font(.body.bold())
                            .disabled(!valid)
                    }
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
