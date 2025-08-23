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

    @AppStorage(wrappedValue: false, "AutoOpenKeyboard", store: defaults) var autoOpenKeyboard: Bool
    @AppStorage(wrappedValue: Data(), "RecentAlbums", store: defaults) var recentAlbumsData: Data

    @FocusState var isSearchFieldFocused: Bool
    var saveAction: () -> Void

    var recentAlbums: [String] {
        let recentAlbums: [String] = (try? JSONDecoder().decode(
            [String].self,
            from: recentAlbumsData
        )) ?? []
        return recentAlbums.reversed()
    }

    init(
        _ navigator: Binding<Navigator>,
        selection selectedCollection: Binding<PHAssetCollection?>,
        saveAction: @escaping () -> Void
    ) {
        self._navigator = navigator
        self._selectedCollection = selectedCollection
        self.saveAction = saveAction
        UITextField.appearance().clearButtonMode = .whileEditing
    }

    var body: some View {
        NavigationStack(path: $navigator.viewPath) {
            @Bindable var navigator = navigator
            CollectionView(selection: $selectedCollection, saveAction: saveAction)
                .environment(navigator)
                #if !targetEnvironment(macCatalyst)
                .safeAreaInset(edge: .bottom, spacing: 0.0) {
                    if !recentAlbums.isEmpty && isSearchFieldFocused {
                        ScrollView(.horizontal) {
                            HStack(spacing: 6.0) {
                                ForEach(recentAlbums, id: \.self) { albumName in
                                    Button {
                                        navigator.searchTerm = albumName
                                        navigator.debouncingSearchTerm = albumName
                                        isSearchFieldFocused = false
                                    } label: {
                                        Text(albumName)
                                            .font(.subheadline)
                                            .padding(.horizontal, 10.0)
                                            .padding(.vertical, 6.0)
                                            .lineLimit(1)
                                    }
                                    .clipShape(.capsule)
                                    .buttonStyle(.glass)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 10.0)
                            .padding(.top, 1.0)
                        }
                        .scrollIndicators(.hidden)
                    }
                }
                #endif
                .searchable(
                    text: $navigator.debouncingSearchTerm,
                    prompt: "Shared.AlbumOrFolderName"
                )
                #if targetEnvironment(macCatalyst)
                .searchSuggestions {
                    ForEach(recentAlbums, id: \.self) { albumName in
                        Text(albumName)
                            .searchCompletion(albumName)
                    }
                }
                #endif
                .searchFocused($isSearchFieldFocused)
                .scrollDismissesKeyboard(.never)
                .navigationDestination(for: Collection.self) { collection in
                    CollectionView(
                        collection, selection: $selectedCollection, saveAction: saveAction
                    )
                        .environment(navigator)
                }
        }
        .onAppear {
            if autoOpenKeyboard {
                isSearchFieldFocused = true
            }
        }
    }
}
