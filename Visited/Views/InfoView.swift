//
//  WelcomeView.swift
//  Location
//
//  Created by Jack Finnis on 27/07/2022.
//

import SwiftUI
import MessageUI

struct InfoView: View {
    @Environment(\.dismiss) var dismiss
    @State var showShareSheet = false
    @State var showEmailSheet = false
    
    let welcome: Bool
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                VStack(spacing: 10) {
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 70, height: 70)
                        .continuousRadius(15)
                        .shadow(color: .black.opacity(0.2), radius: 5)
                    Text(Constants.name)
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                }
                .horizontallyCentred()
                .padding(.bottom, 30)
                
                VStack(alignment: .leading, spacing: 20) {
                    InfoRow(systemName: "globe.europe.africa.fill", title: "Store Your Places", description: "Keep track of all the places you have visited and want to visit!")
                    InfoRow(systemName: "hand.tap", title: "Add Places Easily", description: "Hold down on the map to add a new place.")
                    InfoRow(systemName: "line.3.horizontal.decrease.circle", title: "Filter Your Places", description: "Filter places you have visited and those on your wishlist.")
                }
                
                Spacer()
                if welcome {
                    Button {
                        dismiss()
                    } label: {
                        Text("Continue")
                            .bigButton()
                    }
                } else {
                    Menu {
                        if MFMailComposeViewController.canSendMail() {
                            Button {
                                showEmailSheet.toggle()
                            } label: {
                                Label("Send us Feedback", systemImage: "envelope")
                            }
                        } else if let url = Emails.mailtoUrl(subject: "\(Constants.name) Feedback"), UIApplication.shared.canOpenURL(url) {
                            Button {
                                UIApplication.shared.open(url)
                            } label: {
                                Label("Send us Feedback", systemImage: "envelope")
                            }
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
                }
            }
            .padding()
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
        .shareSheet(items: [Constants.appUrl], showsSharedAlert: true, isPresented: $showShareSheet)
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
