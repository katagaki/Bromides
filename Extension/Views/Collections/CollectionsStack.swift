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
    @Binding var selectedCollections: [PHAssetCollection]

    @AppStorage(wrappedValue: false, "AutoOpenKeyboard", store: defaults) var autoOpenKeyboard: Bool
    @AppStorage(wrappedValue: false, "NoAlbumSelection", store: defaults) var noAlbumSelection: Bool
    @FocusState var isSearchFieldFocused: Bool

    #if !os(macOS)
    @AppStorage(wrappedValue: Data(), "RecentAlbums", store: defaults) var recentAlbumsData: Data
    var recentAlbums: [String] {
        let recentAlbums: [String] = (try? JSONDecoder().decode(
            [String].self,
            from: recentAlbumsData
        )) ?? []
        return recentAlbums.reversed()
    }
    #endif

    var saveAction: () -> Void

    init(
        _ navigator: Binding<Navigator>,
        selection selectedCollections: Binding<[PHAssetCollection]>,
        saveAction: @escaping () -> Void
    ) {
        self._navigator = navigator
        self._selectedCollections = selectedCollections
        self.saveAction = saveAction
        #if !os(macOS)
        UITextField.appearance().clearButtonMode = .whileEditing
        #endif
    }

    var body: some View {
        NavigationStack(path: $navigator.viewPath) {
            @Bindable var navigator = navigator
            CollectionView(selection: $selectedCollections, saveAction: saveAction)
                .environment(navigator)
                #if os(macOS)
                // Show custom toolbar and search bar on macOS
                // (NavigationStack title/back button/toolbars aren't available in share sheet)
                .toolbarForMac(
                    navigator: self.$navigator,
                    isSearchFieldFocused: $isSearchFieldFocused,
                    saveAction: saveAction,
                    isSaveDisabled: selectedCollections.isEmpty && !noAlbumSelection
                )
                #else
                // Use native search features on iOS
                .searchable(
                    text: $navigator.debouncingSearchTerm,
                    prompt: "Shared.AlbumOrFolderName"
                )
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
                .searchFocused($isSearchFieldFocused)
                .scrollDismissesKeyboard(.never)
                #endif
                .navigationDestination(for: Collection.self) { collection in
                    CollectionView(collection, selection: $selectedCollections, saveAction: saveAction)
                        .environment(navigator)
                        .toolbarForMac(
                            navigator: self.$navigator,
                            isSearchFieldFocused: $isSearchFieldFocused,
                            hasSearchBar: false,
                            saveAction: saveAction,
                            isSaveDisabled: selectedCollections.isEmpty && !noAlbumSelection
                        )
                }
        }
        .onAppear {
            if autoOpenKeyboard {
                isSearchFieldFocused = true
            }
        }
    }
}
