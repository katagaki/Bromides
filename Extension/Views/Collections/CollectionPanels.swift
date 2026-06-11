
import Photos
import SwiftUI

struct CollectionPanels: View {
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
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 150.0), spacing: 10.0)],
                spacing: 10.0
            ) {
                ForEach(collections ?? []) { collection in
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
                                mode: .panels,
                                isSelected: { selectedCollections.isSelected(album) }
                            )
                        }
                        .buttonStyle(.plain)
                    case .folder:
                        NavigationLink(value: collection) {
                            CollectionButtonLabel(
                                collection: collection,
                                mode: .panels
                            )
                        }
                        .buttonStyle(.plain)
                    case .search:
                        Color.clear
                    }
                }
            }
            .padding()
        }
    }
}
