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
    @State var town: String?
    @State var coord = CLLocationCoordinate2D()
    @FocusState var focused: Bool
    
    var new: Bool { vm.selectedPlace == nil }
    var valid: Bool { name.trimmed.isNotEmpty || town != nil }
    var edits: Bool {
        name != vm.selectedPlace?.name ?? "" ||
        type != vm.selectedPlace?.type ?? .visited ||
        coord != vm.selectedPlace?.coordinate ?? vm.selectedCoord ?? vm.mapView?.centerCoordinate
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField(town ?? "Name", text: $name)
                        .focused($focused)
                        .submitLabel(.done)
                        .overlay(alignment: .trailing) {
                            if focused && name.isNotEmpty {
                                Button {
                                    name = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                } header: {
                    VStack(spacing: 20) {
                        ZStack {
                            PlaceViewMap(centreCoord: $coord)
                            Image(systemName: "circle.fill")
                                .foregroundColor(type.color)
                                .font(.title3)
                                .addShadow()
                                .allowsHitTesting(false)
                        }
                        .aspectRatio(1, contentMode: .fit)
                        .continuousRadius(10)
                        .addShadow()
                        .padding(5)
                        
                        Picker("", selection: $type) {
                            ForEach(PlaceType.allCases, id: \.self) { type in
                                Text(type.name)
                            }
                        }
                        .pickerStyle(.segmented)
                        .textCase(nil)
                    }
                }
                .headerProminence(.increased)
                
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
                coord = vm.selectedPlace?.coordinate ?? vm.selectedCoord ?? vm.mapView?.centerCoordinate ?? .init()
                if new {
                    vm.reverseGeocode(coord: coord) { placemark in
                        town = placemark.subLocality ?? placemark.locality ?? ""
                    }
                }
            }
            .interactiveDismissDisabled(edits && !new)
            .navigationTitle(new ? "New Place" : "Edit Place")
            .navigationBarTitleDisplayMode(.inline)
            .animation(.default, value: focused)
            .safeAreaInset(edge: .bottom) {
                if new && !focused {
                    Button(action: savePin) {
                        Text("Add Place")
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
                            .disabled(!valid || !edits)
                    }
                }
            }
        }
        .onDisappear {
            vm.selectedPlace = nil
            vm.selectedCoord = nil
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
        place.name = name.isNotEmpty ? name : town ?? ""
        place.type = type
        place.lat = coord.latitude
        place.long = coord.longitude
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

struct PlaceViewMap: UIViewRepresentable {
    @Binding var centreCoord: CLLocationCoordinate2D
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        mapView.showsUserLocation = true
        mapView.isPitchEnabled = false
        mapView.isRotateEnabled = false
        
        let spanDelta = 0.002
        let span = MKCoordinateSpan(latitudeDelta: spanDelta, longitudeDelta: spanDelta)
        mapView.region = MKCoordinateRegion(center: centreCoord, span: span)
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {}
    
    class Coordinator: NSObject, MKMapViewDelegate {
        let parent: PlaceViewMap
        
        init(parent: PlaceViewMap) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            parent.centreCoord = mapView.centerCoordinate
        }
    }
}
