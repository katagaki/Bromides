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
    @State var thumbnail: UIImage?

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .center, spacing: 6.0) {
                Group {
                    switch collection {
                    case .album( _):
                        if let thumbnail {
                            Image(uiImage: thumbnail)
                                .resizable()
                        } else {
                            Image(.genericAlbum)
                                .resizable()
                        }
                    case .folder( _):
                        Image(.genericFolder)
                            .resizable()
                    }
                }
                .clipShape(.rect(cornerRadius: 6.0))
                .aspectRatio(contentMode: .fill)
                .shadow(radius: 3.0, y: 2.0)
                .frame(width: 72.0, height: 72.0)
                Text(collection.title)
                    .lineLimit(1)
                    .font(.caption)
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
