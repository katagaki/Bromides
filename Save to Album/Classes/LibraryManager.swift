//
//  LibraryManager.swift
//  Bromides
//
//  Created by シン・ジャスティン on 2025/03/23.
//

import Photos
import UIKit

class PhotosLibrary {

    @MainActor
    static func requestAuthorization() async -> PHAuthorizationStatus {
        // IMPORTANT: MUST be async/await API for Swift 6!
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        return status
    }

    static func albumsAndFolders(in path: Collection? = nil) -> [Collection] {
        var items: [Collection] = []
        let options: PHFetchOptions = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "localizedTitle", ascending: true)
        ]
        if let path {
            // Get collections from selected collection
            switch path {
            case .folder(let collection):
                if let collection = collection as? PHCollectionList {
                    let collectionItems: PHFetchResult = PHCollection.fetchCollections(in: collection, options: options)
                    collectionItems.enumerateObjects { (collection, _, _ ) in
                        if collection.canContainAssets {
                            items.append(.album(collection: collection))
                        } else if collection.canContainCollections {
                            items.append(.folder(collection: collection))
                        }
                    }
                }
            default: break
            }
        } else {
            // Get top level collections
            let topLevelItems: PHFetchResult = PHAssetCollection.fetchTopLevelUserCollections(with: options)
            topLevelItems.enumerateObjects { (collection, _, _) in
                if collection.canContainAssets {
                    items.append(.album(collection: collection))
                } else if collection.canContainCollections {
                    items.append(.folder(collection: collection))
                }
            }
        }
        return items
    }

    static func images(in album: PHAssetCollection) -> [PHAsset] {
        var photos: [PHAsset] = []
        let assets = PHAsset.fetchAssets(in: album, options: nil)
        assets.enumerateObjects { (asset, _, _) in
            photos.append(asset)
        }
        return photos
    }

    static func thumbnail(in album: PHAssetCollection) -> PHAsset? {
        return images(in: album).first
    }

    static func image(from asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
        let options = PHImageRequestOptions()
        options.version = .current
        options.resizeMode = .exact
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.isSynchronous = true
        PHImageManager.default().requestImage(
            for: asset,
            targetSize: CGSize(width: 100.0, height: 100.0),
            contentMode: .aspectFill,
            options: options
        ) { image, _ in
            completion(image)
        }
    }

    static func saveImage(data: Data, to album: PHAssetCollection, completion: @escaping (Bool) -> Void) {
        guard let image = UIImage(data: data) else {
            completion(false)
            return
        }
        PHPhotoLibrary.shared().performChanges({
            let imageRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            guard let placeholder = imageRequest.placeholderForCreatedAsset else {
                completion(false)
                return
            }
            guard let albumRequest = PHAssetCollectionChangeRequest(for: album) else {
                completion(false)
                return
            }
            let enumeration: NSArray = [placeholder]
            albumRequest.addAssets(enumeration)
        }, completionHandler: { success, error in
            if let error {
                debugPrint(error.localizedDescription)
            }
            completion(success)
        })
    }
}
