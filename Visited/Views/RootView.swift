//
//  RootView.swift
//  Paddle
//
//  Created by Jack Finnis on 11/09/2022.
//

import SwiftUI

struct RootView: View {
    @Environment(\.scenePhase) var scenePhase
    @AppStorage("firstLaunch") var firstLaunch = true
    @StateObject var vm = ViewModel.shared
    @State var showWelcomeView = false
    @State var showInfoView = false

    var body: some View {
        ZStack {
            GeometryReader { geo in
                let disabled = vm.isMapDisabled(geo.size)
                MapView()
                    .disabled(disabled)
                Color.black.opacity(disabled ? 0.15 : 0)
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                CarbonCopy()
                    .id(scenePhase)
                    .blur(radius: 10, opaque: true)
                    .ignoresSafeArea()
                Spacer()
                    .layoutPriority(1)
            }
            
            GeometryReader { geo in
                VStack {
                    HStack {
                        Spacer()
                        if !vm.isMapDisabled(geo.size) {
                            MapButtons()
                        }
                    }
                    Spacer()
                }
            }
            
            Sheet {
                if vm.isSearching && vm.searchScope == .Maps {
                    SearchView()
                } else {
                    PlacesView()
                }
            } header: {
                HStack {
                    SearchBar()
                        .padding(.vertical, -10)
                        .padding(.horizontal, -8)
                    
                    if !vm.isSearching {
                        Button {
                            showInfoView.toggle()
                        } label: {
                            Image(systemName: "info.circle")
                                .font(.icon)
                        }
                        .sheet(isPresented: $showInfoView) {
                            InfoView(welcome: false)
                                .environmentObject(vm)
                        }
                    }
                }
            }
        }
        .task {
            if firstLaunch {
                firstLaunch = false
                showWelcomeView = true
            } else if vm.authStatus == .notDetermined {
                vm.requestLocationAuthorization()
            }
        }
        .background {
            Text("")
                .sheet(isPresented: $showWelcomeView) {
                    InfoView(welcome: true)
                        .environmentObject(vm)
                }
            Text("")
                .sheet(item: $vm.selectedPlace) { place in
                    PlaceView(placeVM: .init(place: place, coord: place.coordinate))
                        .environmentObject(vm)
                }
            Text("")
                .sheet(item: $vm.selectedCoord) { coord in
                    PlaceView(placeVM: .init(place: nil, coord: coord))
                        .environmentObject(vm)
                }
        }
        .environmentObject(vm)
        .navigationViewStyle(.stack)
    }
}
