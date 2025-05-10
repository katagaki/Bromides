//
//  CollectionView.swift
//  Bromides
//
//  Created by シン・ジャスティン on 2025/03/23.
//

import Komponents
import Photos
import SwiftUI

struct CollectionView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(Navigator.self) var navigator
    @AppStorage(wrappedValue: .grid, "DisplayMode", store: defaults) var displayMode: DisplayMode
    @AppStorage(wrappedValue: false, "AutoSelectSearch", store: defaults) var autoSelectFirstSearchResult: Bool

    @State var displayedCollection: Collection?
    @State var collections: [Collection]?
    @State var searchTerm: String?

    @State var isCreatingAlbum: Bool = false
    @State var isCreatingFolder: Bool = false
    @State var newCollectionName: String = ""

    @Binding var selectedCollection: PHAssetCollection?

    init(_ collection: Collection? = nil, selection: Binding<PHAssetCollection?>) {
        self.displayedCollection = collection
        self._selectedCollection = selection
    }

    init(searchTerm: String, selection: Binding<PHAssetCollection?>) {
        self.displayedCollection = .search
        self._selectedCollection = selection
        self.searchTerm = searchTerm
    }

    var body: some View {
        Group {
            switch displayMode {
            case .grid:
                CollectionGrid(collections, selection: $selectedCollection)
            case .list:
                CollectionList(collections, selection: $selectedCollection)
            case .panels:
                CollectionPanels(collections, selection: $selectedCollection)
            }
        }
        .overlay {
            if let collections, collections.isEmpty {
                ContentUnavailableView("Error.NoAlbums", systemImage: "questionmark.square.dashed")
                    .symbolRenderingMode(.multicolor)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0.0) {
            Group {
                #if !targetEnvironment(macCatalyst)
                if verticalSizeClass == .regular && horizontalSizeClass == .compact {
                    bottomSafeAreaOffsetView()
                } else {
                    EmptyView()
                }
                #else
                bottomSafeAreaOffsetView()
                #endif
            }
            .opacity(0.0)
            .allowsHitTesting(false)
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle(displayedCollection == nil ?
                         NSLocalizedString("ViewTitle.SelectAnAlbum", comment: "") :
                            displayedCollection!.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                switch displayedCollection {
                case .folder, nil:
                    Menu {
                        Button("Shared.NewAlbum", systemImage: "photo.on.rectangle.angled", action: startCreatingAlbum)
                        Button("Shared.NewFolder", systemImage: "folder", action: startCreatingFolder)
                    } label: {
                        Label("Shared.New", systemImage: "plus")
                    }
                default:
                    EmptyView()
                }
            }
        }
        .task {
            reloadCollections(animate: false)
        }
        .onChange(of: navigator.searchTerm) { _, newValue in
            if !newValue.trimmingCharacters(in: .whitespaces).isEmpty {
                reloadCollections()
            }
        }
        .alert("Alert.CreateAlbum", isPresented: $isCreatingAlbum) {
            TextField("Alert.CreateAlbum.Name", text: $newCollectionName)
            Button("Shared.Create", action: createAlbum)
            Button("Shared.Cancel", role: .cancel, action: stopCreatingAlbum)
        }
        .alert("Alert.CreateFolder", isPresented: $isCreatingFolder) {
            TextField("Alert.CreateFolder.Name", text: $newCollectionName)
            Button("Shared.Create", action: createFolder)
            Button("Shared.Cancel", role: .cancel, action: stopCreatingFolder)
        }
    }

    @ViewBuilder func bottomSafeAreaOffsetView() -> some View {
        BarAccessory(placement: .bottom) {
            VStack(spacing: 16.0) {
                SearchField(.constant(""), shouldAllowFocus: false)
                Button { } label: {
                    ButtonLabel("Shared.Save", icon: "square.and.arrow.down")
                }
                .buttonStyle(.bordered)
                .padding([.leading, .trailing, .bottom])
            }
        }
    }

    func reloadCollections(animate: Bool = true) {
        if animate {
            withAnimation(.smooth.speed(1.7)) {
                reloadCollections(animate: false)
            }
        } else {
            if displayedCollection == .search {
                collections = PhotosLibrary.albums(containing: navigator.searchTerm)
                if autoSelectFirstSearchResult, let collections, collections.count == 1 {
                    switch collections.first {
                    case .album(let album):
                        selectedCollection = album as? PHAssetCollection
                    default: break
                    }
                }
            } else {
                collections = PhotosLibrary.albumsAndFolders(in: displayedCollection)
            }
        }
    }

    func startCreatingAlbum() {
        newCollectionName = ""
        isCreatingAlbum = true
    }

    func stopCreatingAlbum() {
        isCreatingAlbum = false
        newCollectionName = ""
    }

    func createAlbum() {
        Task {
            if await PhotosLibrary.createAlbum(in: displayedCollection, named: newCollectionName) {
                reloadCollections()
            }
            isCreatingAlbum = false
            newCollectionName = ""
        }
    }

    func startCreatingFolder() {
        newCollectionName = ""
        isCreatingFolder = true
    }

    func stopCreatingFolder() {
        isCreatingFolder = false
        newCollectionName = ""
    }

    func createFolder() {
        Task {
            if await PhotosLibrary.createFolder(in: displayedCollection, named: newCollectionName) {
                reloadCollections()
            }
            isCreatingFolder = false
            newCollectionName = ""
        }
    }
}
