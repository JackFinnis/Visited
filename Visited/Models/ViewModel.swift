//
//  ViewModel.swift
//  Visited
//
//  Created by Jack Finnis on 06/05/2023.
//

import SwiftUI
import MapKit
import CoreData

@MainActor
class ViewModel: NSObject, ObservableObject {
    static let shared = ViewModel()
    
    // MARK: - Properties
    @Published var places = [Place]()
    
    // State
    @Published var selectedPlace: Place?
    @Published var selectedCoord: CLLocationCoordinate2D?
    @Published var showPlaceView = false
    @Published var selectedPlaceType: PlaceType? { didSet {
        mapView?.removeAnnotations(places)
        let filtered = places.filter { selectedPlaceType == nil || $0.type == selectedPlaceType }
        mapView?.addAnnotations(filtered)
        zoomTo(filtered)
    }}
    
    // Animations
    @Published var degrees = 0.0
    @Published var scale = 1.0
    
    // Share
    @Published var showShareSheet = false
    var shareItems = [Any]() { didSet {
        showShareSheet = true
    }}
    
    // MapView
    var mapView: MKMapView?
    @Published var trackingMode = MKUserTrackingMode.none
    @Published var mapType = MKMapType.standard
    
    // CLLocationManager
    let manager = CLLocationManager()
    var authStatus = CLAuthorizationStatus.notDetermined
    @Published var showAuthError = false
    
    // Persistence
    let container = NSPersistentContainer(name: "Visited")
    func save() {
        try? container.viewContext.save()
    }
    
    // MARK: - Initialiser
    override init() {
        super.init()
        manager.delegate = self
        loadPlaces()
    }
    
    func loadPlaces() {
        container.loadPersistentStores { description, error in
            self.places = (try? self.container.viewContext.fetch(Place.fetchRequest()) as? [Place]) ?? []
        }
    }
    
    // MARK: - Methods
    func setTrackingMode(_ newMode: MKUserTrackingMode) {
        guard validateAuth() else { return }
        mapView?.setUserTrackingMode(newMode, animated: true)
        if trackingMode == .followWithHeading || newMode == .followWithHeading {
            withAnimation(.easeInOut(duration: 0.25)) {
                scale = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.trackingMode = newMode
                withAnimation(.easeInOut(duration: 0.25)) {
                    self.scale = 1
                }
            }
        } else {
            trackingMode = newMode
        }
    }
    
    func setMapType(_ newType: MKMapType) {
        mapView?.mapType = newType
        withAnimation(.easeInOut(duration: 0.25)) {
            degrees += 90
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.mapType = newType
            withAnimation(.easeInOut(duration: 0.25)) {
                self.degrees += 90
            }
        }
    }
    
    func zoomTo(_ places: [Place]) {
        let coords = places.map(\.coordinate)
        if coords.isNotEmpty {
            setRect(MKPolyline(coordinates: coords, count: coords.count).boundingMapRect)
        }
    }
    
    func setRect(_ rect: MKMapRect) {
        let padding = 40.0
        let insets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        mapView?.setVisibleMapRect(rect, edgePadding: insets, animated: true)
    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    func deletePlace(_ place: Place) {
        mapView?.removeAnnotation(place)
        places.removeAll { $0.coordinate == place.coordinate }
        container.viewContext.delete(place)
        save()
    }
    
    func reverseGeocode(coord: CLLocationCoordinate2D, completion: @escaping (CLPlacemark) -> Void) {
        CLGeocoder().reverseGeocodeLocation(coord.location) { placemarks, error in
            guard let placemark = placemarks?.first else { return }
            completion(placemark)
        }
    }
}

extension ViewModel: MKMapViewDelegate {
    func getButton(systemName: String) -> UIButton {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(font: .systemFont(ofSize: Constants.size/2))
        let image = UIImage(systemName: systemName, withConfiguration: config)
        button.setImage(image, for: .normal)
        button.frame.size = CGSize(width: Constants.size, height: Constants.size)
        return button
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let place = annotation as? Place else { return nil }
        let pin = mapView.dequeueReusableAnnotationView(withIdentifier: MKPinAnnotationView.id, for: place) as? MKPinAnnotationView
        let options = getButton(systemName: "ellipsis.circle")
        options.menu = UIMenu(children: [
            UIAction(title: "Open in Maps", image: UIImage(systemName: "map")) { _ in
                self.reverseGeocode(coord: place.coordinate) { placemark in
                    let mapItem = MKMapItem(placemark: MKPlacemark(placemark: placemark))
                    mapItem.name = place.name
                    mapItem.openInMaps()
                }
            },
            UIAction(title: "Edit Place", image: UIImage(systemName: "pencil")) { _ in
                self.selectedPlace = place
                self.showPlaceView = true
            },
            UIAction(title: "Share...", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                let coord = place.coordinate
                guard let url = URL(string: "https://maps.apple.com/?ll=\(coord.latitude),\(coord.longitude)") else { return }
                self.shareItems = [url]
            }
        ])
        options.showsMenuAsPrimaryAction = true
        pin?.rightCalloutAccessoryView = options
        pin?.pinTintColor = UIColor(place.type.color)
        pin?.displayPriority = .required
        pin?.animatesDrop = true
        pin?.canShowCallout = true
        return pin
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        let view = mapView.view(for: mapView.userLocation)
        view?.rightCalloutAccessoryView = getButton(systemName: "plus")
    }
    
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        if !animated {
            setTrackingMode(.none)
        }
    }
    
    @objc
    func tappedCompass() {
        guard trackingMode == .followWithHeading else { return }
        setTrackingMode(.follow)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let user = view.annotation as? MKUserLocation {
            selectedCoord = user.coordinate
            showPlaceView = true
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension ViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authStatus = manager.authorizationStatus
        if authStatus == .denied {
            showAuthError = true
        } else if authStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
    }
    
    func validateAuth() -> Bool {
        showAuthError = authStatus == .denied
        return !showAuthError
    }
}

// MARK: - UIGestureRecognizer
extension ViewModel: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool { true }
    
    func getCoord(from gesture: UIGestureRecognizer) -> CLLocationCoordinate2D? {
        guard let mapView = mapView else { return nil }
        let point = gesture.location(in: mapView)
        return mapView.convert(point, toCoordinateFrom: mapView)
    }
    
    @objc
    func handlePress(_ press: UILongPressGestureRecognizer) {
        guard press.state == .began, let coord = getCoord(from: press) else { return }
        Haptics.tap()
        selectedCoord = coord
        showPlaceView = true
    }
}
