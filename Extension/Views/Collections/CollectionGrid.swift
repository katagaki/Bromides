//
//  CollectionGrid.swift
//  Bromides
//
//  Created by シン・ジャスティン on 2025/04/05.
//

import Photos
import SwiftUI

struct CollectionGrid: View {
    var collections: [Collection]?
    var navigator: Navigator
    var allowMultipleSelection: Bool

    init(
        _ collections: [Collection]?,
        navigator: Navigator,
        allowMultipleSelection: Bool = true
    ) {
        self.collections = collections
        self.navigator = navigator
        self.allowMultipleSelection = allowMultipleSelection
    }

    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 80.0), spacing: 10.0)],
                spacing: 10.0
            ) {
                ForEach(collections ?? []) { collection in
                    switch collection {
                    case .album(let album):
                        if let album = album as? PHAssetCollection {
                            Button {
                                withAnimation(.smooth.speed(2.0)) {
                                    navigator.toggleAlbumSelection(album, allowMultiple: allowMultipleSelection)
                                }
                            } label: {
                                CollectionButtonLabel(
                                    collection: collection,
                                    mode: .grid,
                                    isSelected: { navigator.isAlbumSelected(album) }
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    case .folder:
                        NavigationLink(value: collection) {
                            CollectionButtonLabel(
                                collection: collection,
                                mode: .grid
                            )
                        }
                        .buttonStyle(.plain)
                    case .search:
                        Color.clear
                    }
                }
            }
            .padding()
        }
    }
}
