//
//  SearchResultRow.swift
//  Visited
//
//  Created by Jack Finnis on 25/07/2023.
//

import SwiftUI
import MapKit

struct SearchResultRow: View {
    @EnvironmentObject var vm: ViewModel
    
    let result: MKMapItem
    
    var body: some View {
        Button {
            vm.selectAnnotation(result)
            if let rect = result.placemark.region?.rect {
                vm.setRect(rect)
            }
        } label: {
            let category = result.pointOfInterestCategory
            
            HStack(spacing: 0) {
                Image(systemName: "circle.fill")
                    .font(.title)
                    .foregroundColor(category?.color ?? MKPointOfInterestCategory.defaultColor)
                    .overlay {
                        Group {
                            if let category {
                                Image(category.rawValue)
                                    .renderingMode(.template)
                                    .resizable()
                                    .frame(width: 20, height: 20)
                            } else {
                                Image(systemName: MKPointOfInterestCategory.defaultIcon)
                                    .font(.subheadline)
                            }
                        }
                        .foregroundColor(.white)
                    }
                    .padding(.trailing, 10)
                VStack(alignment: .leading, spacing: 0) {
                    Text(result.title ?? "")
                        .font(.headline)
                    Text(result.subtitle ?? "")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .listRowBackground(Color.clear)
    }
}
