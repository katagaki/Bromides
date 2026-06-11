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
    @Binding var selectedCollections: [PHAssetCollection]

    @AppStorage(wrappedValue: false, "MultipleAlbumSelection", store: defaults) var multipleAlbumSelection: Bool

    init(
        _ collections: [Collection]?,
        selection selectedCollections: Binding<[PHAssetCollection]>
    ) {
        self.collections = collections
        self._selectedCollections = selectedCollections
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
                        Button {
                            if let album = album as? PHAssetCollection {
                                withAnimation(.smooth.speed(2.0)) {
                                    selectedCollections.toggle(album, allowingMultiple: multipleAlbumSelection)
                                }
                            }
                        } label: {
                            CollectionButtonLabel(
                                collection: collection,
                                mode: .grid,
                                isSelected: { selectedCollections.isSelected(album) }
                            )
                        }
                        .buttonStyle(.plain)
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
