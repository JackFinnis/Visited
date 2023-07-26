//
//  WelcomeView.swift
//  Location
//
//  Created by Jack Finnis on 27/07/2022.
//

import SwiftUI
import MessageUI

struct InfoView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: ViewModel
    @State var showShareSheet = false
    @State var showEmailSheet = false
    
    let welcome: Bool
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(spacing: 10) {
                        Image("logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 70, height: 70)
                            .continuousRadius(15)
                            .shadow()
                        Text(Constants.name)
                            .font(.largeTitle.bold())
                            .multilineTextAlignment(.center)
                    }
                    .horizontallyCentred()
                    .padding(.bottom, 30)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        InfoRow(systemName: "globe.europe.africa.fill", title: "Remember Your Travels", description: "Browse all the places you have visited and lived.")
                        InfoRow(systemName: "checklist", title: "Complete Your Bucket List", description: "Keep track of where you want to visit in future.")
                        InfoRow(systemName: "hand.tap", title: "Easily Save Places", description: "Hold down on the map to drop a pin at that location.")
                    }
                }
                .padding(.horizontal)
                .frame(maxWidth: 450)
                .horizontallyCentred()
            }
            .safeAreaInset(edge: .bottom) {
                Group {
                    if welcome {
                        Button {
                            dismiss()
                            vm.requestLocationAuthorization()
                        } label: {
                            Text("Continue")
                                .bigButton()
                        }
                    } else {
                        Menu {
                            Button {
                                if MFMailComposeViewController.canSendMail() {
                                    showEmailSheet.toggle()
                                } else if let url = Emails.url(subject: "\(Constants.name) Feedback") {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                Label("Send us Feedback", systemImage: "envelope")
                            }
                            Button {
                                Store.writeReview()
                            } label: {
                                Label("Write a Review", systemImage: "quote.bubble")
                            }
                            Button {
                                Store.requestRating()
                            } label: {
                                Label("Rate \(Constants.name)", systemImage: "star")
                            }
                            Button {
                                showShareSheet.toggle()
                            } label: {
                                Label("Share \(Constants.name)", systemImage: "square.and.arrow.up")
                            }
                        } label: {
                            Text("Contribute...")
                                .bigButton()
                        }
                        .sharePopover(items: [Constants.appUrl], showsSharedAlert: true, isPresented: $showShareSheet)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .frame(maxWidth: 450)
                .horizontallyCentred()
            }
            .interactiveDismissDisabled(welcome)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    if welcome {
                        Text("")
                    } else {
                        DraggableTitle()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    if !welcome {
                        Button {
                            dismiss()
                        } label: {
                            DismissCross()
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .emailSheet(recipient: Constants.email, subject: "\(Constants.name) Feedback", isPresented: $showEmailSheet)
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        Text("")
            .sheet(isPresented: .constant(true)) {
                InfoView(welcome: true)
            }
    }
}

struct InfoRow: View {
    let systemName: String
    let title: String
    let description: String
    
    var body: some View {
        HStack {
            Image(systemName: systemName)
                .font(.title)
                .foregroundColor(.accentColor)
                .frame(width: 50, height: 50)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .foregroundColor(.secondary)
            }
        }
    }
}
