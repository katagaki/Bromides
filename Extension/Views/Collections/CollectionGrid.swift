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
    @Binding var selectedCollection: PHAssetCollection?

    init(
        _ collections: [Collection]?,
        selection selectedCollection: Binding<PHAssetCollection?>
    ) {
        self.collections = collections
        self._selectedCollection = selectedCollection
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
                            withAnimation(.smooth.speed(2.0)) {
                                selectedCollection = album as? PHAssetCollection
                            }
                        } label: {
                            CollectionButtonLabel(
                                collection: collection,
                                mode: .grid,
                                isSelected: { selectedCollection == album }
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
