//
//  ListBuffer.swift
//  Visited
//
//  Created by Jack Finnis on 25/07/2023.
//

import SwiftUI

struct ListBuffer: View {
    let isPresented: Bool
    
    var body: some View {
        if isPresented {
            Spacer()
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
        }
    }
}
