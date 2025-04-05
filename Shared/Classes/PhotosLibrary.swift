//
//  PhotosLibrary.swift
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
        items.sort(by: { $0.title.localizedStandardCompare($1.title) == .orderedAscending })
        return items
    }

    static func albums(containing searchTerm: String) -> [Collection] {
        var items: [Collection] = []
        let options: PHFetchOptions = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "localizedTitle", ascending: true)
        ]
        let collections: PHFetchResult = PHAssetCollection.fetchAssetCollections(
            with: .album, subtype: .any, options: options
        )
        collections.enumerateObjects { (collection, _, _) in
            items.append(.album(collection: collection))
        }
        items.removeAll(where: { !$0.title.localizedCaseInsensitiveContains(
            searchTerm.trimmingCharacters(in: .whitespaces)
        ) })
        items.sort(by: { $0.title.localizedStandardCompare($1.title) == .orderedAscending })
        return items
    }

    static func createAlbum(in path: Collection? = nil, named name: String) async -> Bool {
        do {
            try await PHPhotoLibrary.shared().performChanges {
                let newAlbumRequest: PHAssetCollectionChangeRequest = PHAssetCollectionChangeRequest
                    .creationRequestForAssetCollection(withTitle: name)
                if let path {
                    let placeholder: PHObjectPlaceholder? = newAlbumRequest.placeholderForCreatedAssetCollection
                    switch path {
                    case .folder(let collection):
                        if let collection = collection as? PHCollectionList {
                            let albumRequest = PHCollectionListChangeRequest(for: collection)
                            let enumeration: NSArray = [placeholder!]
                            albumRequest?.addChildCollections(enumeration)
                        } else {
                            debugPrint(collection.self)
                        }
                    default: break
                    }
                }
            }
            return true
        } catch {
            debugPrint(error.localizedDescription)
            return false
        }
    }

    static func createFolder(in path: Collection? = nil, named name: String) async -> Bool {
        do {
            try await PHPhotoLibrary.shared().performChanges {
                let newFolderRequest: PHCollectionListChangeRequest = PHCollectionListChangeRequest
                    .creationRequestForCollectionList(withTitle: name)
                if let path {
                    let placeholder: PHObjectPlaceholder? = newFolderRequest.placeholderForCreatedCollectionList
                    switch path {
                    case .folder(let collection):
                        if let collection = collection as? PHCollectionList {
                            let albumRequest = PHCollectionListChangeRequest(for: collection)
                            let enumeration: NSArray = [placeholder!]
                            albumRequest?.addChildCollections(enumeration)
                        } else {
                            debugPrint(collection.self)
                        }
                    default: break
                    }
                }
            }
            return true
        } catch {
            debugPrint(error.localizedDescription)
            return false
        }
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

    static func saveImage(data: Data, to album: PHAssetCollection) async -> Bool {
        guard let image = UIImage(data: data) else { return false }
        do {
            try await PHPhotoLibrary.shared().performChanges {
                let imageRequest: PHAssetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                let placeholder: PHObjectPlaceholder? = imageRequest.placeholderForCreatedAsset
                let albumRequest = PHAssetCollectionChangeRequest(for: album)
                let enumeration: NSArray = [placeholder!]
                albumRequest!.addAssets(enumeration)
            }
            return true
        } catch {
            debugPrint(error.localizedDescription)
            return false
        }
    }

    enum PLError: Error {
        case noPlaceholder
        case noAlbumRequest
    }
}
