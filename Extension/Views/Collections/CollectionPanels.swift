//
//  CollectionPanels.swift
//  Bromides
//
//  Created by シン・ジャスティン on 2025/04/05.
//

import Photos
import SwiftUI

struct CollectionPanels: View {
    var collections: [Collection]?
    var navigator: Navigator

    init(
        _ collections: [Collection]?,
        navigator: Navigator
    ) {
        self.collections = collections
        self.navigator = navigator
    }

    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 150.0), spacing: 10.0)],
                spacing: 10.0
            ) {
                ForEach(collections ?? []) { collection in
                    switch collection {
                    case .album(let album):
                        if let album = album as? PHAssetCollection {
                            Button {
                                withAnimation(.smooth.speed(2.0)) {
                                    navigator.toggleAlbumSelection(album)
                                }
                            } label: {
                                CollectionButtonLabel(
                                    collection: collection,
                                    mode: .panels,
                                    isSelected: { navigator.isAlbumSelected(album) }
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    case .folder:
                        NavigationLink(value: collection) {
                            CollectionButtonLabel(
                                collection: collection,
                                mode: .panels
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
