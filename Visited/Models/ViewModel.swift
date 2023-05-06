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
    var places = [Place]()
    
    // State
    @Published var selectedPlace: Place?
    @Published var selectedCoord: CLLocationCoordinate2D?
    @Published var showPlaceView = false
    @Published var showInfoView = false
    @Published var welcome = false
    
    // Animations
    @Published var degrees = 0.0
    @Published var scale = 1.0
    
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
        // Load Core Data
        container.loadPersistentStores { description, error in
            self.loadPlaces()
        }
    }
    
    func loadPlaces() {
        places = (try? container.viewContext.fetch(Place.fetchRequest()) as? [Place]) ?? []
        mapView?.addAnnotations(places)
        let coords = places.map(\.coordinate)
        setRect(MKPolyline(coordinates: coords, count: coords.count).boundingMapRect)
    }
    
    // MARK: - Methods
    func updateTrackingMode(_ newMode: MKUserTrackingMode) {
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
    
    func updateMapType(_ newType: MKMapType) {
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
}

extension ViewModel: MKMapViewDelegate {
    func getButton(systemName: String) -> UIButton {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(font: .systemFont(ofSize: SIZE/2))
        let image = UIImage(systemName: systemName, withConfiguration: config)
        button.setImage(image, for: .normal)
        button.frame.size = CGSize(width: SIZE, height: SIZE)
        return button
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let place = annotation as? Place else { return nil }
        let editButton = getButton(systemName: "pencil")
        let pin = mapView.dequeueReusableAnnotationView(withIdentifier: MKPinAnnotationView.id, for: annotation) as? MKPinAnnotationView
        pin?.rightCalloutAccessoryView = editButton
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
            updateTrackingMode(.none)
        }
    }
    
    @objc
    func tappedCompass() {
        guard trackingMode == .followWithHeading else { return }
        updateTrackingMode(.follow)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let place = view.annotation as? Place {
            selectedPlace = place
            showPlaceView = true
        } else if view.annotation is MKUserLocation {
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
