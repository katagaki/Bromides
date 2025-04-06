//
//  CollectionsStack.swift
//  Bromides
//
//  Created by シン・ジャスティン on 2025/04/06.
//

import Photos
import SwiftUI

struct CollectionsStack: View {
    @Binding var navigator: Navigator
    @Binding var selectedCollection: PHAssetCollection?

    init(_ navigator: Binding<Navigator>, selection selectedCollection: Binding<PHAssetCollection?>) {
        self._navigator = navigator
        self._selectedCollection = selectedCollection
    }

    var body: some View {
        NavigationStack(path: $navigator.viewPath) {
            CollectionView(selection: $selectedCollection)
                .environment(navigator)
                .navigationDestination(for: Collection.self) { collection in
                    CollectionView(collection, selection: $selectedCollection)
                        .environment(navigator)
                }
        }
        .onChange(of: navigator.searchTerm) { _, newValue in
            if !newValue.trimmingCharacters(in: .whitespaces).isEmpty {
                navigator.startSearching()
            } else if newValue.trimmingCharacters(in: .whitespaces).isEmpty {
                navigator.stopSearching()
            }
        }
        .onChange(of: navigator.viewPath) { oldValue, newValue in
            if oldValue.contains(.search) && !newValue.contains(.search) {
                navigator.stopSearching()
            }
        }
    }
}
