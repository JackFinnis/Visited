//
//  View.swift
//  News
//
//  Created by Jack Finnis on 13/01/2023.
//

import SwiftUI

extension View {
    func centred() -> some View {
        self.horizontallyCentred()
            .verticallyCentred()
    }
    
    func verticallyCentred() -> some View {
        VStack {
            Spacer()
            self
            Spacer()
        }
    }
    
    func horizontallyCentred() -> some View {
        HStack(spacing: 0) {
            Spacer(minLength: 0)
            self
            Spacer(minLength: 0)
        }
    }
    
    func shadow() -> some View {
        shadow(color: Color.black.opacity(0.2), radius: 5, y: 5)
    }
    
    func squareButton() -> some View {
        self.font(.icon)
            .frame(width: Constants.size, height: Constants.size)
    }
    
    func blurBackground() -> some View {
        self.background(.thickMaterial, ignoresSafeAreaEdges: .all)
            .continuousRadius(10)
            .compositingGroup()
            .shadow()
    }
    
    func continuousRadius(_ cornerRadius: CGFloat) -> some View {
        clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
    
    func bigButton() -> some View {
        self
            .font(.headline)
            .padding()
            .horizontallyCentred()
            .foregroundColor(.white)
            .background(Color.accentColor)
            .continuousRadius(15)
    }
    
    @ViewBuilder
    func `if`<Content: View>(_ applyModifier: Bool = true, @ViewBuilder content: (Self) -> Content) -> some View {
        if applyModifier {
            content(self)
        } else {
            self
        }
    }
}

struct RoundedCorners: Shape {
    let radius: CGFloat
    let corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
