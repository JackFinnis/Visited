//
//  SearchBar.swift
//  Paddle
//
//  Created by Jack Finnis on 14/09/2022.
//

import SwiftUI

extension UISearchBar {
    var cancelButton: UIButton? {
        value(forKey: "cancelButton") as? UIButton
    }
}

struct SearchBar: UIViewRepresentable {
    @EnvironmentObject var vm: ViewModel
    
    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.delegate = vm
        vm.searchBar = searchBar
        
        searchBar.backgroundImage = UIImage()
        searchBar.scopeBarBackgroundImage = UIImage()
        searchBar.scopeButtonTitles = SearchScope.allCases.map(\.rawValue)
        searchBar.autocorrectionType = .no
        
        return searchBar
    }
    
    func updateUIView(_ searchBar: UISearchBar, context: Context) {
        if vm.isSearching {
            searchBar.placeholder = "Search \(vm.searchScope.rawValue)"
        } else {
            searchBar.placeholder = "Search Places & Maps"
        }
    }
}
