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
    @Published var allPlaceTypes = Set<PlaceType>()
    @Published var countriesVisited = 0
    @Published var places: [Place] = [] { didSet {
        allPlaceTypes = Set(places.map(\.type))
        countriesVisited = Set(places.map(\.placemark.country).compactMap { $0 }).count
    }}
    @Published var filteredPlaces: [Place] = []
    var isFiltering: Bool { placeFilter != nil || isSearching }
    @Published var placeFilter: PlaceFilter? { didSet {
        filterPlaces()
        zoomToFilteredPlaces()
    }}
    
    // State
    @Published var selectedPlace: Place?
    @Published var selectedCoord: CLLocationCoordinate2D?
    
    // Animations
    @Published var degrees = 0.0
    @Published var scale = 1.0
    
    // MapView
    var mapView: _MKMapView?
    @Published var trackingMode = MKUserTrackingMode.none
    @Published var mapType = MKMapType.standard
    
    // CLLocationManager
    let locationManager = CLLocationManager.shared
    var authStatus = CLAuthorizationStatus.notDetermined
    @Published var showAuthError = false
    
    // Persistence
    let container = NSPersistentContainer(name: "Visited")
    func save() {
        try? container.viewContext.save()
    }
    
    // Search
    var searchBar: UISearchBar?
    var searchRect: MKMapRect?
    var localSearch: MKLocalSearch?
    var previousSearch: Search?
    let searchCompleter = MKLocalSearchCompleter()
    
    @Published var searchScope = SearchScope.Places
    @Published var searchLoading = false
    @Published var isSearching = false
    @Published var isEditing = false
    @Published var searchCompletions = [MKLocalSearchCompletion]()
    @Published var searchResults = [MKMapItem]()
    @Published var searchText = "" { didSet {
        searchBar?.text = searchText
        updateSearchCompletions()
    }}
    
    // Storage
    @Storage("recentSearches") var recentSearches = [String]() { didSet {
        objectWillChange.send()
    }}
    func removeRecentSearch(_ string: String) {
        recentSearches.removeAll { $0.lowercased() == string.lowercased() }
    }
    func addRecentSearch(_ string: String) {
        removeRecentSearch(string)
        recentSearches.append(string)
    }
    
    @Storage("ascending") var ascending = false
    @Storage("sortBy") var sortBy = PlaceSort.Name { didSet {
        if oldValue == sortBy {
            ascending.toggle()
        }
        sortPlaces()
    }}
    
    // MARK: - Sheet
    @Published var headerSize = CGSize()
    @Published var sheetDetent = SheetDetent.small
    
    // Dimensions
    var unsafeSafeAreaSize: CGSize {
        mapView?.safeAreaLayoutGuide.layoutFrame.size ?? .zero
    }
    
    func isCompact(_ size: CGSize) -> Bool {
        HorizontalSizeClass(size) == .compact
    }
    
    func isMapDisabled(_ size: CGSize) -> Bool {
        sheetDetent == .large && isCompact(size)
    }
    
    func getMaxSheetWidth(_ size: CGSize) -> CGFloat {
        HorizontalSizeClass(size).maxSheetWidth
    }
    
    func getTopSheetPadding(_ size: CGSize) -> CGFloat {
        isCompact(size) ? 20 : 10
    }
    
    func getHorizontalSheetPadding(_ size: CGSize) -> CGFloat {
        isCompact(size) ? 0 : 10
    }
    
    func getMediumSheetDetent(_ size: CGSize) -> CGFloat {
        VerticalSizeClass(size).mediumSheetDetent
    }
    
    func getSpacerHeight(_ size: CGSize, detent: SheetDetent) -> CGFloat {
        size.height - getDetentHeight(size, detent: detent)
    }
    
    func getAvailableDetents(_ size: CGSize) -> [SheetDetent] {
        if isCompact(size) {
            return SheetDetent.allCases
        } else {
            return [.small, .large]
        }
    }
    
    func getDetentHeight(_ size: CGSize, detent: SheetDetent) -> CGFloat {
        switch detent {
        case .large:
            return size.height - getTopSheetPadding(size)
        case .medium:
            return getMediumSheetDetent(size)
        case .small:
            return headerSize.height
        }
    }
    
    func setSheetDetent(_ detent: SheetDetent) {
        refreshCompass()
        withAnimation(.sheet) {
            sheetDetent = detent
        }
        if isEditing && detent != .large {
            stopEditing()
        }
    }
    
    func refreshCompass() {
        UIView.animate(withDuration: 0.3) {
            self.mapView?.compass?.alpha = self.isMapDisabled(self.unsafeSafeAreaSize) ? 0 : 1
        }
    }
    
    // MARK: - Initialiser
    override init() {
        super.init()
        locationManager.delegate = self
        searchCompleter.delegate = self
        loadPlaces()
    }
    
    // MARK: - Methods
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - Places
    func loadPlaces() {
        container.loadPersistentStores { description, error in
            self.places = self.fetch(Place.self)
            self.filterPlaces()
        }
    }
    
    func fetch<T: NSManagedObject>(_ entity: T.Type) -> [T] {
        (try? self.container.viewContext.fetch(T.fetchRequest()) as? [T]) ?? []
    }
    
    func deleteAll(_ entity: NSManagedObject.Type) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entity.id)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try! container.viewContext.execute(deleteRequest)
    }
    
    func filterPlaces() {
        let old = filteredPlaces
        filteredPlaces = places.filter { place in
            let searching = place.name.localizedCaseInsensitiveContains(searchText) || searchText.isEmpty
            let filter: Bool
            switch placeFilter {
            case nil:
                filter = true
            case .type(let type):
                filter = place.type == type
            }
            return searching && filter
        }
        sortPlaces()
        mapView?.removeAnnotations(Array(Set(old).subtracting(filteredPlaces)))
        mapView?.addAnnotations(Array(Set(filteredPlaces).subtracting(old)))
    }
    
    func sortPlaces() {
        let sorted = filteredPlaces.sorted {
            switch sortBy {
            case .Name:
                return $0.name < $1.name
            case .Time:
                return $0.placemark.timeZone ?? .current < $1.placemark.timeZone ?? .current
            case .Distance:
                return $0.distance ?? 0 < $1.distance ?? 0
            case .Country:
                return $0.placemark.isoCountryCode ?? "" < $1.placemark.isoCountryCode ?? ""
            }
        }
        filteredPlaces = ascending ? sorted : sorted.reversed()
    }
    
    func deletePlace(_ place: Place) {
        mapView?.removeAnnotation(place)
        places.removeAll(place)
        filteredPlaces.removeAll(place)
        container.viewContext.delete(place)
        save()
    }
    
    // MARK: - Map
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
    
    func zoomToFilteredPlaces() {
        let coords = filteredPlaces.map(\.coordinate)
        if coords.count == 1 {
            selectAnnotation(filteredPlaces.first!)
        } else if coords.isNotEmpty {
            setRect(MKPolyline(coordinates: coords, count: coords.count).boundingMapRect)
        }
    }
    
    func setRect(_ rect: MKMapRect) {
        guard let mapView else { return }
        let size = mapView.safeAreaLayoutGuide.layoutFrame.size
        
        let bottom: CGFloat
        if !isCompact(size) {
            bottom = 0
        } else if sheetDetent == .large {
            bottom = getMediumSheetDetent(size)
        } else {
            bottom = getDetentHeight(size, detent: sheetDetent)
        }
        let left: CGFloat
        if isCompact(size) {
            left = 0
        } else {
            left = getHorizontalSheetPadding(size) + HorizontalSizeClass(size).maxSheetWidth
        }
        
        let padding = 40.0
        let insets = UIEdgeInsets(top: padding, left: padding + left, bottom: padding + bottom, right: padding)
        mapView.setVisibleMapRect(rect, edgePadding: insets, animated: true)
    }
    
    func selectAnnotation(_ annotation: MKAnnotation) {
        mapView?.selectAnnotation(annotation, animated: true)
        ensureMapVisible()
    }
    
    func centerAnnotation(_ annotation: MKAnnotation) {
        let delta = 0.01
        let span = MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
        let rect = MKCoordinateRegion(center: annotation.coordinate, span: span).rect
        setRect(rect)
    }
    
    func reverseGeocode(coord: CLLocationCoordinate2D, completion: @escaping (CLPlacemark) -> Void) {
        CLGeocoder().reverseGeocodeLocation(coord.location) { placemarks, error in
            guard let placemark = placemarks?.first else { return }
            completion(placemark)
        }
    }
    
    func ensureMapVisible() {
        stopEditing()
        if isCompact(unsafeSafeAreaSize) && sheetDetent == .large {
            setSheetDetent(.medium)
        }
    }
}

// MARK: - MKMapViewDelegate
extension ViewModel: MKMapViewDelegate {
    func getButton(systemName: String) -> UIButton {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(font: .systemFont(ofSize: Constants.size/2))
        let image = UIImage(systemName: systemName, withConfiguration: config)
        button.setImage(image, for: .normal)
        button.frame.size = CGSize(width: Constants.size, height: Constants.size)
        return button
    }
    
    func openInMaps(_ place: Place) {
        reverseGeocode(coord: place.coordinate) { placemark in
            let mapItem = MKMapItem(placemark: MKPlacemark(placemark: placemark))
            mapItem.name = place.name
            mapItem.openInMaps()
        }
    }
    
    func sharePlace(_ place: Place) {
        let coord = place.coordinate
        guard let mapView, let url = URL(string: "https://maps.apple.com/?ll=\(coord.latitude),\(coord.longitude)") else { return }
        let point = mapView.convert(coord, toPointTo: mapView)
        let shareVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        shareVC.popoverPresentationController?.sourceView = mapView
        shareVC.popoverPresentationController?.sourceRect = CGRect(origin: point, size: .zero)
        mapView.window?.rootViewController?.present(shareVC, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let place = annotation as? Place {
            let pin = mapView.dequeueReusableAnnotationView(withIdentifier: MKPinAnnotationView.id, for: place) as? MKPinAnnotationView
            let options = getButton(systemName: "ellipsis.circle")
            options.menu = UIMenu(children: [
                UIAction(title: "Open in Maps", image: UIImage(systemName: "map")) { _ in
                    self.openInMaps(place)
                },
                UIAction(title: "Edit Place", image: UIImage(systemName: "pencil")) { _ in
                    self.selectedPlace = place
                },
                UIAction(title: "Share...", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                    self.sharePlace(place)
                }
            ])
            options.showsMenuAsPrimaryAction = true
            pin?.rightCalloutAccessoryView = options
            pin?.pinTintColor = UIColor(place.type.color)
            pin?.displayPriority = .required
            pin?.animatesDrop = true
            pin?.canShowCallout = true
            return pin
        } else if let result = annotation as? MKMapItem {
            let marker = mapView.dequeueReusableAnnotationView(withIdentifier: MKMarkerAnnotationView.id, for: annotation) as? MKMarkerAnnotationView
            marker?.displayPriority = .required
            marker?.animatesWhenAdded = true
            marker?.canShowCallout = true
            marker?.rightCalloutAccessoryView = getButton(systemName: "plus")
            if let category = result.pointOfInterestCategory {
                marker?.glyphImage = UIImage(systemName: category.systemName)
                marker?.markerTintColor = UIColor(category.color)
            }
            return marker
        }
        return nil
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
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        selectedCoord = view.annotation?.coordinate
    }
}

// MARK: - CLLocationManagerDelegate
extension ViewModel: CLLocationManagerDelegate {
    func requestLocationAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ locationManager: CLLocationManager) {
        authStatus = locationManager.authorizationStatus
        validateAuth()
    }
    
    @discardableResult func validateAuth() -> Bool {
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
    }
    
    @objc
    func tappedCompass() {
        guard trackingMode == .followWithHeading else { return }
        setTrackingMode(.follow)
    }
}

// MARK: - UISearchBarDelegate
extension ViewModel: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        switch searchScope {
        case .Places:
            zoomToFilteredPlaces()
            stopEditing()
        case .Maps:
            searchText = searchText.trimmed
            guard searchText.isNotEmpty else { return }
            searchMaps(.string(searchText))
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        withAnimation(.sheet) {
            searchScope = SearchScope.allCases[selectedScope]
        }
        startEditing()
        updateSearchCompletions()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        stopSearching()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        startEditing()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        ensureMapVisible()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange text: String) {
        searchText = text
    }
    
    func updateSearchCompletions() {
        switch searchScope {
        case .Places:
            filterPlaces()
        case .Maps:
            fetchCompletions()
        }
    }
    
    func startEditing() {
        isEditing = true
        isSearching = true
        setSheetDetent(.large)
        searchBar?.becomeFirstResponder()
        searchBar?.setShowsScope(true, animated: false)
        searchBar?.setShowsCancelButton(true, animated: false)
    }
    
    func stopEditing() {
        isEditing = false
        searchBar?.resignFirstResponder()
        searchBar?.cancelButton?.isEnabled = true
    }
    
    func stopSearching() {
        searchText = ""
        resetSearching()
        isSearching = false
        searchBar?.setShowsScope(false, animated: false)
        searchBar?.setShowsCancelButton(false, animated: false)
        ensureMapVisible()
    }
    
    func stopSearchRequest() {
        localSearch?.cancel()
        searchLoading = false
    }
    
    func resetSearching() {
        mapView?.removeAnnotations(searchResults)
        searchResults = []
        stopSearchRequest()
        searchRect = nil
    }
    
    func searchMaps(_ newSearch: Search?) {
        previousSearch = newSearch ?? previousSearch
        guard let mapView, let search = previousSearch else { return }
        
        let request: MKLocalSearch.Request
        switch search {
        case .string(let string):
            request = .init()
            request.naturalLanguageQuery = string
            searchText = string
        case .completion(let completion):
            request = .init(completion: completion)
            searchText = completion.title
        }
        
        addRecentSearch(searchText)
        request.region = mapView.region
        request.resultTypes = [.address, .pointOfInterest]
        
        stopEditing()
        ensureMapVisible()
        searchRect = mapView.visibleMapRect
        resetSearching()
        localSearch = MKLocalSearch(request: request)
        searchLoading = true
        
        localSearch?.start { response, error in
            self.searchLoading = false
            guard let response else { return }
            let results = response.mapItems
            
            mapView.addAnnotations(results)
            if results.count == 1 {
                self.selectAnnotation(results.first!)
                if self.isCompact(self.unsafeSafeAreaSize) {
                    self.setSheetDetent(.small)
                }
            }
            
            self.searchResults = results
            self.setRect(response.boundingRegion.rect)
        }
    }
}

// MARK: - MKLocalSearchCompleterDelegate
extension ViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchCompletions = completer.results
    }
    
    func fetchCompletions() {
        guard let mapView else { return }
        if searchText.isEmpty {
            searchCompletions = []
        } else {
            searchCompleter.cancel()
            searchCompleter.queryFragment = searchText
            searchCompleter.region = mapView.region
            searchCompleter.resultTypes = [.address, .pointOfInterest, .query]
        }
    }
}
