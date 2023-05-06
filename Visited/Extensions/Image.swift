//
//  Image.swift
//  News
//
//  Created by Jack Finnis on 24/03/2023.
//

import SwiftUI

extension Image {
    init(systemName: String, fontSize: Double, tint: Color) {
        let tintConfig = UIImage.SymbolConfiguration(paletteColors: [UIColor(tint)])
        let fontConfig = UIImage.SymbolConfiguration(font: .systemFont(ofSize: fontSize))
        var uiImage = UIImage(systemName: systemName)!
        uiImage = uiImage.applyingSymbolConfiguration(tintConfig)!
        uiImage = uiImage.applyingSymbolConfiguration(fontConfig)!
        self.init(uiImage: uiImage)
    }
}
