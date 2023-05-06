//
//  View.swift
//  News
//
//  Created by Jack Finnis on 13/01/2023.
//

import SwiftUI

extension View {
    func horizontallyCentred() -> some View {
        HStack {
            Spacer(minLength: 0)
            self
            Spacer(minLength: 0)
        }
    }
    
    func addShadow() -> some View {
        shadow(color: Color.black.opacity(0.2), radius: 5)
    }
    
    func squareButton() -> some View {
        self.font(.system(size: SIZE/2))
            .frame(width: SIZE, height: SIZE)
    }
    
    func blurBackground() -> some View {
        self.background(.thickMaterial, ignoresSafeAreaEdges: .all)
            .continuousRadius(10)
            .compositingGroup()
            .addShadow()
    }
    
    func continuousRadius(_ cornerRadius: CGFloat) -> some View {
        clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
    
    func bigButton() -> some View {
        self
            .font(.body.bold())
            .padding()
            .horizontallyCentred()
            .foregroundColor(.white)
            .background(Color.accentColor)
            .continuousRadius(15)
    }
}
