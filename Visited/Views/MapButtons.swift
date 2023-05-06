//
//  ActionButtons.swift
//  Trails
//
//  Created by Jack Finnis on 19/02/2023.
//

import SwiftUI
import MapKit

struct MapButtons: View {
    @EnvironmentObject var vm: ViewModel
    @State var showInfoView = false
    
    var body: some View {
        VStack(spacing: 10) {
            VStack(spacing: 0) {
                Button {
                    updateMapType()
                } label: {
                    Image(systemName: mapTypeImage)
                        .squareButton()
                        .rotation3DEffect(.degrees(vm.mapType == .standard ? 0 : 180), axis: (x: 0, y: 1, z: 0))
                        .rotation3DEffect(.degrees(vm.degrees), axis: (x: 0, y: 1, z: 0))
                }
                
                Divider().frame(width: SIZE)
                Button {
                    updateTrackingMode()
                } label: {
                    Image(systemName: trackingModeImage)
                        .scaleEffect(vm.scale)
                        .squareButton()
                }
            }
            .blurBackground()
            
            VStack(spacing: 0) {
                Button {
                    showInfoView = true
                } label: {
                    Image(systemName: "info.circle")
                        .squareButton()
                }
                
                if Set(vm.places.map(\.type)).count == PlaceType.allCases.count {
                    Divider().frame(width: SIZE)
                    Menu {
                        Picker("", selection: $vm.selectedPlaceType) {
                            Text("All Pins")
                                .tag(nil as PlaceType?)
                            ForEach(PlaceType.allCases, id: \.self) { type in
                                Label {
                                    Text(type.name)
                                } icon: {
                                    Image(systemName: "circle.fill", fontSize: 20, tint: type.color)
                                }
                                .tag(type as PlaceType?)
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle\(vm.selectedPlaceType == nil ? "" : ".fill")")
                            .squareButton()
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .blurBackground()
        }
        .animation(.default, value: vm.places)
        .padding(10)
        .alert("Access Denied", isPresented: $vm.showAuthError) {
            Button("Maybe Later") {}
            Button("Settings", role: .cancel) {
                vm.openSettings()
            }
        } message: {
            Text("\(NAME) needs access to your location to show where you are on the map. Please go to Settings > \(NAME) > Location and allow access while using the app.")
        }
        .sheet(isPresented: $showInfoView) {
            InfoView(welcome: false)
        }
    }
    
    func updateTrackingMode() {
        var mode: MKUserTrackingMode {
            switch vm.trackingMode {
            case .none:
                return .follow
            case .follow:
                return .followWithHeading
            default:
                return .none
            }
        }
        vm.setTrackingMode(mode)
    }
    
    func updateMapType() {
        var type: MKMapType {
            switch vm.mapType {
            case .standard:
                return .hybrid
            default:
                return .standard
            }
        }
        vm.setMapType(type)
    }
    
    var trackingModeImage: String {
        switch vm.trackingMode {
        case .none:
            return "location"
        case .follow:
            return "location.fill"
        default:
            return "location.north.line.fill"
        }
    }
    
    var mapTypeImage: String {
        switch vm.mapType {
        case .standard:
            return "globe.europe.africa.fill"
        default:
            return "map"
        }
    }
}

struct MapButtons_Previews: PreviewProvider {
    static var previews: some View {
        MapButtons()
            .environmentObject(ViewModel())
    }
}
