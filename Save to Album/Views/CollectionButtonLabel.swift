//
//  CollectionButton.swift
//  Bromides
//
//  Created by シン・ジャスティン on 2025/03/23.
//

import Photos
import SwiftUI

struct CollectionButtonLabel: View {
    var collection: Collection
    var mode: CollectionButtonMode
    @State var thumbnail: UIImage?
    var isSelected: (() -> Bool)?

    var body: some View {
        Group {
            switch mode {
            case .thumbnail:
                HStack(alignment: .top) {
                    VStack(alignment: .center, spacing: 6.0) {
                        Group {
                            switch collection {
                            case .album:
                                if let thumbnail {
                                    Image(uiImage: thumbnail)
                                        .resizable()
                                } else {
                                    Image(.genericAlbum)
                                        .resizable()
                                }
                            case .folder:
                                Image(.genericFolder)
                                    .resizable()
                            }
                        }
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 72.0, height: 72.0)
                        .overlay {
                            if let isSelected, isSelected() {
                                ZStack(alignment: .center) {
                                    Color(uiColor: .systemBackground).opacity(0.3)
                                    Image(systemName: "checkmark.circle.fill")
                                        .resizable()
                                        .symbolRenderingMode(.multicolor)
                                        .frame(width: 28.0, height: 28.0)
                                        .overlay {
                                            Circle()
                                                .stroke(.white, lineWidth: 2.0)
                                        }
                                }
                            }
                        }
                        .compositingGroup()
                        .clipShape(.rect(cornerRadius: 6.0))
                        .shadow(radius: 3.0, y: 2.0)
                        Text(collection.title)
                            .lineLimit(1)
                            .font(.caption)
                    }
                }
            case .row:
                HStack(alignment: .center, spacing: 16.0) {
                    Group {
                        switch collection {
                        case .album:
                            if let thumbnail {
                                Image(uiImage: thumbnail)
                                    .resizable()
                            } else {
                                Image(.genericAlbum)
                                    .resizable()
                            }
                        case .folder:
                            Image(.genericFolder)
                                .resizable()
                        }
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 38.0, height: 38.0)
                    .overlay {
                        if let isSelected, isSelected() {
                            ZStack(alignment: .center) {
                                Color(uiColor: .systemBackground).opacity(0.3)
                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .symbolRenderingMode(.multicolor)
                                    .frame(width: 18.0, height: 18.0)
                                    .overlay {
                                        Circle()
                                            .stroke(.white, lineWidth: 2.0)
                                    }
                            }
                        }
                    }
                    .compositingGroup()
                    .clipShape(.rect(cornerRadius: 6.0))
                    .shadow(radius: 3.0, y: 2.0)
                    Text(collection.title)
                        .font(.body)
                        .layoutPriority(0)
                }
            }
        }
        .task {
            fetchThumbnail()
        }
    }

    func fetchThumbnail() {
        switch collection {
        case .album(let collection):
            if let album = collection as? PHAssetCollection,
               let imageAsset = PhotosLibrary.thumbnail(in: album) {
                PhotosLibrary.image(from: imageAsset) { uiImage in
                    thumbnail = uiImage
                }
            }
        default: break
        }
    }
}
