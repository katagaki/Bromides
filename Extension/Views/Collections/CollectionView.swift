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

    var saveAction: () -> Void

    @Binding var selectedCollection: PHAssetCollection?

    init(
        _ collection: Collection? = nil,
        selection: Binding<PHAssetCollection?>,
        saveAction: @escaping () -> Void
    ) {
        self.displayedCollection = collection
        self._selectedCollection = selection
        self.saveAction = saveAction
    }

    init(
        searchTerm: String,
        selection: Binding<PHAssetCollection?>,
        saveAction: @escaping () -> Void
    ) {
        self.displayedCollection = .search
        self._selectedCollection = selection
        self.searchTerm = searchTerm
        self.saveAction = saveAction
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
        .navigationTitle(displayedCollection == nil ?
                         NSLocalizedString("ViewTitle.SelectAnAlbum", comment: "") :
                            displayedCollection!.title)
        #if os(macOS)
        // Show custom toolbar on macOS
        .safeAreaInset(edge: .bottom, spacing: 0.0) {
            HStack(alignment: .center) {
                switch displayedCollection {
                case .folder, nil: newMenu()
                default: EmptyView()
                }
                Spacer()
                saveButton()
            }
            .frame(maxWidth: .infinity, minHeight: 32.0, maxHeight: 32.0)
            .padding(8.0)
            .background(Material.ultraThin)
            .overlay(alignment: .top) {
                Rectangle()
                    .frame(height: 1.0)
                    .foregroundColor(.primary.opacity(0.2))
                    .ignoresSafeArea(edges: [.leading, .trailing])
            }
        }
        #else
        // Use native toolbar on iOS
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                switch displayedCollection {
                case .folder, nil: newMenu()
                default: EmptyView()
                }
            }
            ToolbarSpacer(.flexible, placement: .bottomBar)
            ToolbarItem(placement: .bottomBar) {
                saveButton()
            }
            ToolbarItem(placement: .topBarTrailing) {
                closeButton()
            }
        }
        #endif
        .task {
            reloadCollections(animate: false)
            checkAndResetSelection()
        }
        .onChange(of: navigator.searchTerm) { _, _ in
            if navigator.isSearching {
                self.displayedCollection = .search
            } else {
                self.displayedCollection = nil
            }
            reloadCollections()
        }
        .onChange(of: collections) { _, _ in
            checkAndResetSelection()
        }
        .alert("Alert.CreateAlbum", isPresented: $isCreatingAlbum) {
            TextField("Alert.CreateAlbum.Name", text: $newCollectionName)
            Button("Shared.Create", role: .confirm, action: createAlbum)
                .disabled(newCollectionName == "")
            Button(role: .cancel, action: stopCreatingAlbum)
        }
        .alert("Alert.CreateFolder", isPresented: $isCreatingFolder) {
            TextField("Alert.CreateFolder.Name", text: $newCollectionName)
            Button("Shared.Create", role: .confirm, action: createFolder)
                .disabled(newCollectionName == "")
            Button(role: .cancel, action: stopCreatingFolder)
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

    func checkAndResetSelection() {
        if !(collections ?? []).contains(where: {
            $0.id == selectedCollection?.localIdentifier
        }) {
            selectedCollection = nil
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

    @ViewBuilder
    func newMenu() -> some View {
        Menu {
            Button("Shared.NewAlbum", systemImage: "photo.on.rectangle.angled", action: startCreatingAlbum)
            Button("Shared.NewFolder", systemImage: "folder", action: startCreatingFolder)
        } label: {
            Label("Shared.New", systemImage: "plus")
            #if os(macOS)
                .frame(height: 32.0)
                .padding(.horizontal, 8.0)
                .contentShape(.rect)
            #endif
        }
        #if os(macOS)
        .menuStyle(.borderlessButton)
        .frame(height: 32.0)
        .padding(.horizontal, 8.0)
        .glassEffect(.regular.interactive(), in: .capsule)
        #endif
    }

    @ViewBuilder
    func saveButton() -> some View {
        Group {
            #if os(macOS)
            Button(role: .confirm, action: saveAction) {
                Label("Shared.Save", systemImage: "square.and.arrow.down")
                    .frame(height: 32.0)
                    .padding(.horizontal, 8.0)
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .frame(height: 32.0)
            .glassEffect(.regular.interactive().tint(.accent), in: .capsule)
            #else
            Button(
                "Shared.Save",
                systemImage: "square.and.arrow.down",
                role: .confirm,
                action: saveAction
            )
            #endif
        }
        .disabled(selectedCollection == nil)
    }

    @ViewBuilder
    func closeButton() -> some View {
        Button(role: .cancel, action: close)
    }
}
