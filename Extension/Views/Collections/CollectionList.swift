//
//  CollectionList.swift
//  Bromides
//
//  Created by シン・ジャスティン on 2025/04/05.
//

import Photos
import SwiftUI

struct CollectionList: View {
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
        List(collections ?? []) { collection in
            Group {
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
                            mode: .list,
                            isSelected: { selectedCollections.isSelected(album) }
                        )
                        #if os(macOS)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(.rect)
                        #endif
                    }
                    #if os(macOS)
                    .buttonStyle(.plain)
                    #endif
                case .folder:
                    NavigationLink(value: collection) {
                        CollectionButtonLabel(
                            collection: collection,
                            mode: .list
                        )
                    }
                case .search:
                    Color.clear
                }
            }
            .listRowInsets(.init(top: 6.0, leading: 20.0, bottom: 6.0, trailing: 20.0))
        }
        .listStyle(.plain)
    }
}
