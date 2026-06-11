
import Photos
import SwiftUI

struct SelectedAlbumsView: View {
    @Environment(\.dismiss) var dismiss

    @Binding var selectedCollections: [PHAssetCollection]

    init(selection selectedCollections: Binding<[PHAssetCollection]>) {
        self._selectedCollections = selectedCollections
    }

    var body: some View {
        List(selectedCollections, id: \.localIdentifier) { collection in
            HStack(alignment: .center, spacing: 16.0) {
                CollectionButtonLabel(
                    collection: .album(collection: collection),
                    mode: .list
                )
                Spacer(minLength: 0.0)
                Button {
                    withAnimation(.smooth.speed(2.0)) {
                        selectedCollections.removeAll(where: {
                            $0.localIdentifier == collection.localIdentifier
                        })
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("Shared.Remove"))
            }
            .listRowInsets(.init(top: 6.0, leading: 20.0, bottom: 6.0, trailing: 20.0))
        }
        .listStyle(.plain)
        .frame(
            minWidth: 280.0,
            minHeight: min(CGFloat(max(selectedCollections.count, 1)) * 50.0 + 12.0, 312.0)
        )
        .onChange(of: selectedCollections) { _, newValue in
            if newValue.isEmpty {
                dismiss()
            }
        }
    }
}
