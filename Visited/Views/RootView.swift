//
//  RootView.swift
//  Paddle
//
//  Created by Jack Finnis on 11/09/2022.
//

import SwiftUI

struct RootView: View {
    @AppStorage("launchedBefore") var launchedBefore = false
    @StateObject var vm = ViewModel.shared

    var body: some View {
        ZStack(alignment: .trailing) {
            MapView()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                CarbonCopy()
                    .blur(radius: 10, opaque: true)
                    .ignoresSafeArea()
                Spacer()
                    .layoutPriority(1)
            }
            
            VStack(alignment: .trailing) {
                MapButtons()
                Spacer()
                Button {
                    vm.showPlaceView = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(Color.accentColor)
                        .clipShape(Circle())
                        .addShadow()
                }
                .padding()
            }
        }
        .task {
            if !launchedBefore {
                launchedBefore = true
                vm.welcome = true
                vm.showInfoView = true
            }
        }
        .sheet(isPresented: $vm.showInfoView) {
            InfoView(welcome: vm.welcome)
        }
        .sheet(isPresented: $vm.showPlaceView, onDismiss: {
            vm.selectedPlace = nil
        }) {
            PlaceView()
        }
        .environmentObject(vm)
    }
}
