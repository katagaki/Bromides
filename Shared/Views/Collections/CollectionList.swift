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
    @Binding var selectedCollection: PHAssetCollection?

    init(_ collections: [Collection]?, selection selectedCollection: Binding<PHAssetCollection?>) {
        self.collections = collections
        self._selectedCollection = selectedCollection
    }

    var body: some View {
        List(collections ?? []) { collection in
            Group {
                switch collection {
                case .album(let album):
                    Button {
                        withAnimation(.smooth.speed(2.0)) {
                            selectedCollection = album as? PHAssetCollection
                        }
                    } label: {
                        CollectionButtonLabel(
                            collection: collection,
                            mode: .list,
                            isSelected: { selectedCollection == album }
                        )
                    }
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
