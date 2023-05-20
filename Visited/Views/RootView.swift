//
//  RootView.swift
//  Paddle
//
//  Created by Jack Finnis on 11/09/2022.
//

import SwiftUI

struct RootView: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("launchedBefore") var launchedBefore = false
    @StateObject var vm = ViewModel.shared
    @State var showWelcomeView = false

    var body: some View {
        ZStack(alignment: .trailing) {
            MapView()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                CarbonCopy()
                    .id(colorScheme)
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
                showWelcomeView = true
            }
        }
        .sheet(isPresented: $showWelcomeView) {
            InfoView(welcome: true)
        }
        .sheet(isPresented: $vm.showPlaceView) {
            PlaceView()
        }
        .environmentObject(vm)
        .navigationViewStyle(.stack)
        .shareSheet(items: vm.shareItems, isPresented: $vm.showShareSheet)
    }
}
