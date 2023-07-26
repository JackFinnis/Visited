//
//  PlaceView.swift
//  Visited
//
//  Created by Jack Finnis on 06/05/2023.
//

import SwiftUI
import MapKit

struct PlaceView: View {
    @MainActor class PlaceVM: ObservableObject {
        @Published var type: PlaceType
        @Published var name: String
        @Published var placemark: CLPlacemark?
        var coord: CLLocationCoordinate2D
        
        let place: Place?
        let initialCoord: CLLocationCoordinate2D
        
        var new: Bool { place == nil }
        var valid: Bool { name.trimmed.isNotEmpty && placemark != nil }
        var unchanged: Bool {
            name == place?.name ?? placemark?.name ?? "" &&
            type == place?.type ?? .visited &&
            coord == place?.coordinate ?? initialCoord
        }
        
        init(place: Place?, coord: CLLocationCoordinate2D) {
            self.place = place
            self.placemark = place?.placemark
            self.initialCoord = coord
            self.type = place?.type ?? .visited
            self.name = place?.name ?? ""
            self.coord = coord
        }
    }
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: ViewModel
    @FocusState var focused: Bool
    @StateObject var placeVM: PlaceVM
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Name", text: $placeVM.name)
                        .focused($focused)
                        .submitLabel(.done)
                        .padding(.trailing, 30)
                        .overlay(alignment: .trailing) {
                            if focused && placeVM.name.isNotEmpty {
                                Button {
                                    placeVM.name = ""
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
                            PlaceViewMap(centreCoord: $placeVM.coord)
                            Image(systemName: "circle.fill")
                                .foregroundColor(placeVM.type.color)
                                .font(.title3)
                                .shadow()
                                .allowsHitTesting(false)
                        }
                        .aspectRatio(1, contentMode: .fit)
                        .continuousRadius(10)
                        .shadow()
                        
                        Picker("Place Type", selection: $placeVM.type) {
                            ForEach(PlaceType.allCases, id: \.self) { type in
                                Text(type.name)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.bottom, 10)
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
            .interactiveDismissDisabled(!placeVM.unchanged)
            .navigationTitle(placeVM.new ? "New Place" : "Edit Place")
            .navigationBarTitleDisplayMode(.inline)
            .animation(.default, value: focused)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(placeVM.new ? "Add" : "Save", action: savePin)
                        .font(.headline)
                        .disabled(!placeVM.valid || !placeVM.new && placeVM.unchanged)
                }
            }
        }
        .onAppear {
            if placeVM.new {
                vm.reverseGeocode(coord: placeVM.coord) { placemark in
                    placeVM.placemark = placemark
                    placeVM.name = placeVM.placemark?.name ?? ""
                }
            }
        }
    }
    
    func savePin() {
        guard let placemark = placeVM.placemark else { return }
        let place = placeVM.place ?? Place(context: vm.container.viewContext)
        place.name = placeVM.name.trimmed
        place.type = placeVM.type
        place.lat = placeVM.coord.latitude
        place.long = placeVM.coord.longitude
        place.placemark = placemark
        vm.save()
        vm.places.removeAll(place)
        vm.places.append(place)
        vm.filterPlaces()
        Haptics.tap()
        dismiss()
    }
}

struct PlaceView_Previews: PreviewProvider {
    static var previews: some View {
        Text("")
            .sheet(isPresented: .constant(true)) {
                PlaceView(placeVM: .init(place: nil, coord: .init()))
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
        mapView.mapType = .hybrid
        
        let spanDelta = 0.001
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
