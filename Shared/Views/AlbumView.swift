//
//  AlbumView.swift
//  Bromides
//
//  Created by シン・ジャスティン on 2025/03/23.
//

import Photos
import SwiftUI

struct AlbumView: View {
    @AppStorage(wrappedValue: .grid, "DisplayMode", store: defaults) var displayMode: DisplayMode

    @State var displayedCollection: Collection?
    @State var collections: [Collection] = []

    @Binding var selectedCollection: PHAssetCollection?

    init(_ collection: Collection? = nil, selection: Binding<PHAssetCollection?>) {
        self.displayedCollection = collection
        self._selectedCollection = selection
    }

    var body: some View {
        Group {
            switch displayMode {
            case .grid:
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80.0), spacing: 10.0)],
                              spacing: 10.0) {
                        ForEach(collections) { collection in
                            switch collection {
                            case .album(let album):
                                Button {
                                    withAnimation(.smooth.speed(2.0)) {
                                        selectedCollection = album as? PHAssetCollection
                                    }
                                } label: {
                                    CollectionButtonLabel(
                                        collection: collection,
                                        mode: .thumbnail,
                                        isSelected: { selectedCollection == album }
                                    )
                                }
                                .buttonStyle(.plain)
                            case .folder:
                                NavigationLink(value: collection) {
                                    CollectionButtonLabel(
                                        collection: collection,
                                        mode: .thumbnail
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding()
                }
            case .list:
                List(collections) { collection in
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
                                    mode: .row,
                                    isSelected: { selectedCollection == album }
                                )
                            }
                        case .folder:
                            NavigationLink(value: collection) {
                                CollectionButtonLabel(
                                    collection: collection,
                                    mode: .row
                                )
                            }
                        }
                    }
                    .listRowInsets(.init(top: 6.0, leading: 20.0, bottom: 6.0, trailing: 20.0))
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle(displayedCollection == nil ?
                         NSLocalizedString("ViewTitle.SelectAnAlbum", comment: "") :
                            displayedCollection!.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            collections = PhotosLibrary.albumsAndFolders(in: displayedCollection)
        }
        .overlay {
            if collections.isEmpty {
                ContentUnavailableView("Error.NoAlbums", systemImage: "questionmark.square.dashed")
                    .symbolRenderingMode(.multicolor)
            }
        }
    }
}
