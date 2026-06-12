
import Komponents
import Photos
import SwiftUI

struct CollectionView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(Navigator.self) var navigator

    @AppStorage(wrappedValue: .grid, "DisplayMode", store: defaults) var displayMode: DisplayMode
    @AppStorage(wrappedValue: false, "AutoSelectSearch", store: defaults) var autoSelectFirstSearchResult: Bool
    @AppStorage(wrappedValue: .everywhere, "SearchScope", store: defaults) var searchScope: SearchScope
    @AppStorage(wrappedValue: false, "MultipleAlbumSelection", store: defaults) var multipleAlbumSelection: Bool
    @AppStorage(wrappedValue: false, "NoAlbumSelection", store: defaults) var noAlbumSelection: Bool

    var baseCollection: Collection?
    @State var displayedCollection: Collection?
    @State var collections: [Collection]?

    @State var isCreatingAlbum: Bool = false
    @State var isCreatingFolder: Bool = false
    @State var newCollectionName: String = ""
    @State var isSelectionPopoverPresented: Bool = false

    var saveAction: () -> Void

    @Binding var selectedCollections: [PHAssetCollection]

    var hasNewMenu: Bool {
        switch displayedCollection {
        case .folder, nil: return true
        default: return false
        }
    }

    init(
        _ collection: Collection? = nil,
        selection: Binding<[PHAssetCollection]>,
        saveAction: @escaping () -> Void
    ) {
        self.baseCollection = collection
        self.displayedCollection = collection
        self._selectedCollections = selection
        self.saveAction = saveAction
    }

    var body: some View {
        Group {
            switch displayMode {
            case .grid:
                CollectionGrid(collections, selection: $selectedCollections)
            case .list:
                CollectionList(collections, selection: $selectedCollections)
            case .panels:
                CollectionPanels(collections, selection: $selectedCollections)
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
            VStack(alignment: .center, spacing: 8.0) {
                if hasNewMenu || multipleAlbumSelection {
                    HStack(alignment: .center) {
                        if hasNewMenu {
                            newMenu()
                        }
                        Spacer()
                        if multipleAlbumSelection {
                            selectionSummaryButton()
                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 32.0, maxHeight: 32.0)
                }
                saveButton()
            }
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
            ToolbarItem(placement: .topBarTrailing) {
                cancelButton()
            }
            if hasNewMenu {
                ToolbarItem(placement: .bottomBar) {
                    newMenu()
                }
            }
            ToolbarSpacer(.flexible, placement: .bottomBar)
            if multipleAlbumSelection {
                ToolbarItem(placement: .bottomBar) {
                    selectionSummaryButton()
                }
                ToolbarSpacer(.flexible, placement: .bottomBar)
            }
            ToolbarItem(placement: .bottomBar) {
                saveButton()
            }
        }
        #endif
        .task {
            reloadCollections(animate: false)
        }
        .onAppear {
            checkAndResetSelection()
        }
        .onChange(of: navigator.searchTerm) { _, _ in
            if navigator.isSearching {
                self.displayedCollection = .search
            } else {
                self.displayedCollection = baseCollection
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
                collections = PhotosLibrary.albumsAndFolders(
                    matching: navigator.searchTerm,
                    in: searchScope == .currentFolder ? baseCollection : nil
                )
                if autoSelectFirstSearchResult {
                    // Folders cannot be saved to, so only the first album is auto selected
                    let firstAlbum: PHAssetCollection? = (collections ?? [])
                        .lazy
                        .compactMap { collection -> PHAssetCollection? in
                            if case .album(let album) = collection {
                                return album as? PHAssetCollection
                            }
                            return nil
                        }
                        .first
                    if let firstAlbum, !selectedCollections.isSelected(firstAlbum) {
                        selectedCollections.toggle(firstAlbum, allowingMultiple: multipleAlbumSelection)
                    }
                }
            } else {
                collections = PhotosLibrary.albumsAndFolders(in: displayedCollection)
            }
        }
    }

    func checkAndResetSelection() {
        // Keep selections made in other albums and folders when selecting multiple albums
        if !multipleAlbumSelection {
            selectedCollections.removeAll { selectedCollection in
                !(collections ?? []).contains(where: {
                    $0.id == selectedCollection.localIdentifier
                })
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
            Button(action: saveAction) {
                Label("Shared.Save", systemImage: "square.and.arrow.down")
                    .bold()
                    .frame(maxWidth: .infinity, minHeight: 32.0, maxHeight: 32.0)
                    .contentShape(.rect)
            }
            .buttonStyle(.borderedProminent)
            .clipShape(.capsule)
            #else
            Button(action: saveAction) {
                Label("Shared.Save", systemImage: "square.and.arrow.down")
            }
            .buttonStyle(.borderedProminent)
            .clipShape(.capsule)
            #endif
        }
        .accessibilityLabel(Text("Shared.Save"))
        .disabled(selectedCollections.isEmpty && !noAlbumSelection)
    }

    @ViewBuilder
    func cancelButton() -> some View {
        Button(role: .cancel, action: close)
            .accessibilityLabel(Text("Shared.Cancel"))
    }

    @ViewBuilder
    func selectionSummaryButton() -> some View {
        Button {
            isSelectionPopoverPresented = true
        } label: {
            Text("Shared.AlbumsSelected.\(selectedCollections.count)")
            #if os(macOS)
                .frame(height: 32.0)
                .padding(.horizontal, 8.0)
                .contentShape(.rect)
            #endif
        }
        #if os(macOS)
        .buttonStyle(.plain)
        .frame(height: 32.0)
        .glassEffect(.regular.interactive(), in: .capsule)
        #endif
        .disabled(selectedCollections.isEmpty)
        .popover(isPresented: $isSelectionPopoverPresented) {
            SelectedAlbumsView(selection: $selectedCollections)
                .presentationCompactAdaptation(.popover)
        }
    }
}
