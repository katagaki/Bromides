//
//  AlbumView.swift
//  Bromides
//
//  Created by シン・ジャスティン on 2025/03/23.
//

import Photos
import SwiftUI

struct AlbumView: View {
    @State var displayedCollection: Collection?
    @State var collections: [Collection] = []

    @Binding var selectedCollection: PHAssetCollection?

    init(_ collection: Collection? = nil, selection: Binding<PHAssetCollection?>) {
        self.displayedCollection = collection
        self._selectedCollection = selection
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80.0), spacing: 4.0)],
                      spacing: 10.0) {
                ForEach(collections) { collection in
                    switch collection {
                    case .album(let album):
                        Button {
                            selectedCollection = album as? PHAssetCollection
                        } label: {
                            CollectionButtonLabel(collection: collection)
                        }
                        .buttonStyle(.plain)
                        .overlay {
                            if selectedCollection == album {
                                ZStack(alignment: .center) {
                                    Color.clear
                                    Image(systemName: "checkmark.circle.fill")
                                }
                            }
                        }
                    case .folder( _):
                        NavigationLink(value: collection) {
                            CollectionButtonLabel(collection: collection)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
                      .padding(.horizontal, 12.0)
        }
        .navigationTitle(displayedCollection == nil ? "Select an Album" : displayedCollection!.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            collections = PhotosLibrary.albumsAndFolders(in: displayedCollection)
        }
    }
}
