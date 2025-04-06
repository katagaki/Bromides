//
//  CollectionCover.swift
//  Bromides
//
//  Created by シン・ジャスティン on 2025/04/05.
//

import Photos
import SwiftUI

struct CollectionCover: View {
    var collection: Collection
    var iconSize: CGFloat
    @State var thumbnail: UIImage?

    init(_ collection: Collection, iconSize: CGFloat) {
        self.collection = collection
        self.iconSize = iconSize
    }

    var body: some View {
        ZStack {
            switch collection {
            case .album:
                if let thumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                } else {
                    GenericThumbnail(
                        text: collection.title,
                        iconName: "photo.on.rectangle.angled",
                        iconSize: iconSize
                    )
                }
            case .folder:
                GenericThumbnail(
                    text: collection.title,
                    iconName: "folder",
                    iconSize: iconSize
                )
            case .search:
                Color.clear
            }
        }
        .aspectRatio(contentMode: .fill)
        .task(priority: .background) {
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
