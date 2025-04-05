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
    @AppStorage(wrappedValue: .grid, "DisplayMode", store: defaults) var displayMode: DisplayMode
    @Environment(Navigator.self) var navigator

    @State var displayedCollection: Collection?
    @State var collections: [Collection] = []
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
            if collections.isEmpty {
                ContentUnavailableView("Error.NoAlbums", systemImage: "questionmark.square.dashed")
                    .symbolRenderingMode(.multicolor)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0.0) {
            BarAccessory(placement: .bottom) {
                VStack(spacing: 16.0) {
                    SearchField()
                    HStack {
                        ButtonLabel("Shared.Save", icon: "square.and.arrow.down")
                    }
                }
                .padding()
            }
            .opacity(0.0)
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
            if !newValue.isEmpty {
                reloadCollections(animate: false)
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

    func reloadCollections(animate: Bool = true) {
        if animate {
            withAnimation {
                reloadCollections(animate: false)
            }
        } else {
            if displayedCollection == .search {
                collections = PhotosLibrary.albums(containing: navigator.searchTerm)
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
