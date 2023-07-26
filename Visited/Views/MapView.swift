//
//  MapView.swift
//  Paddle
//
//  Created by Jack Finnis on 11/09/2022.
//

import SwiftUI
import MapKit

class _MKMapView: MKMapView {
    var compass: UIView? {
        subviews.first(where: { type(of: $0).id == "MKCompassView" })
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let compass else { return }
        compass.center = compass.center.applying(.init(translationX: -5, y: Constants.size*3 + 25))
        if compass.gestureRecognizers?.count == 1 {
            let tap = UITapGestureRecognizer(target: ViewModel.shared, action: #selector(ViewModel.tappedCompass))
            tap.delegate = ViewModel.shared
            compass.addGestureRecognizer(tap)
        }
    }
}

struct MapView: UIViewRepresentable {
    @EnvironmentObject var vm: ViewModel
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = _MKMapView()
        mapView.delegate = vm
        vm.mapView = mapView
        
        mapView.showsUserLocation = true
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.isPitchEnabled = false
        mapView.userTrackingMode = .none
        
        mapView.register(MKPinAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKPinAnnotationView.id)
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMarkerAnnotationView.id)
        
        let pressRecognizer = UILongPressGestureRecognizer(target: vm, action: #selector(ViewModel.handlePress))
        mapView.addGestureRecognizer(pressRecognizer)
        
        mapView.addAnnotations(vm.places)
        vm.zoomToFilteredPlaces()
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {}
}
