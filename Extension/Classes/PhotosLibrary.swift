
import Photos
#if os(macOS)
import AppKit
#else
import UIKit
#endif

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

    static func albumsAndFolders(matching searchTerm: String, in path: Collection? = nil) -> [Collection] {
        let trimmedSearchTerm = searchTerm.trimmingCharacters(in: .whitespacesAndNewlines)
        let searchTokens = trimmedSearchTerm
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        guard !searchTokens.isEmpty else { return [] }
        var candidates: [Collection] = []
        if let path, case .folder(let collection) = path, let folder = collection as? PHCollectionList {
            candidates = albumsAndFoldersRecursively(in: folder)
        } else {
            let options: PHFetchOptions = PHFetchOptions()
            options.sortDescriptors = [
                NSSortDescriptor(key: "localizedTitle", ascending: true)
            ]
            let albums: PHFetchResult = PHAssetCollection.fetchAssetCollections(
                with: .album, subtype: .any, options: options
            )
            albums.enumerateObjects { (collection, _, _) in
                candidates.append(.album(collection: collection))
            }
            let folders: PHFetchResult = PHCollectionList.fetchCollectionLists(
                with: .folder, subtype: .any, options: options
            )
            folders.enumerateObjects { (collection, _, _) in
                candidates.append(.folder(collection: collection))
            }
        }
        var fullMatches: [Collection] = []
        var tokenMatches: [Collection] = []
        for candidate in candidates {
            let title = candidate.title
            if title.localizedCaseInsensitiveContains(trimmedSearchTerm) {
                fullMatches.append(candidate)
            } else if searchTokens.contains(where: { title.localizedCaseInsensitiveContains($0) }) {
                tokenMatches.append(candidate)
            }
        }
        fullMatches.sort(by: { $0.title.localizedStandardCompare($1.title) == .orderedAscending })
        tokenMatches.sort(by: { $0.title.localizedStandardCompare($1.title) == .orderedAscending })
        return fullMatches + tokenMatches
    }

    static func albumsAndFoldersRecursively(in folder: PHCollectionList) -> [Collection] {
        var items: [Collection] = []
        let collectionItems: PHFetchResult = PHCollection.fetchCollections(in: folder, options: nil)
        collectionItems.enumerateObjects { (collection, _, _) in
            if collection.canContainAssets {
                items.append(.album(collection: collection))
            } else if collection.canContainCollections {
                items.append(.folder(collection: collection))
            }
        }
        for item in items {
            if case .folder(let collection) = item, let childFolder = collection as? PHCollectionList {
                items.append(contentsOf: albumsAndFoldersRecursively(in: childFolder))
            }
        }
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

    static func image(from asset: PHAsset, completion: @escaping (XPImage?) -> Void) {
        let options = PHImageRequestOptions()
        options.version = .current
        options.resizeMode = .fast
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true
        options.isSynchronous = false
        PHImageManager.default().requestImage(
            for: asset,
            targetSize: CGSize(width: 100.0, height: 100.0),
            contentMode: .aspectFill,
            options: options
        ) { image, _ in
            completion(image)
        }
    }

    static func saveImage(data: Data) async -> Bool {
        guard let image = XPImage(data: data) else { return false }
        do {
            try await PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
            return true
        } catch {
            debugPrint(error.localizedDescription)
            return false
        }
    }

    static func saveImage(data: Data, to album: PHAssetCollection) async -> Bool {
        return await saveImage(data: data, to: [album])
    }

    static func saveImage(data: Data, to albums: [PHAssetCollection]) async -> Bool {
        guard let image = XPImage(data: data) else { return false }
        do {
            try await PHPhotoLibrary.shared().performChanges {
                // Save a single copy of the image, then assign it to every album.
                let imageRequest: PHAssetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                let placeholder: PHObjectPlaceholder? = imageRequest.placeholderForCreatedAsset
                let enumeration: NSArray = [placeholder!]
                for album in albums {
                    let albumRequest = PHAssetCollectionChangeRequest(for: album)
                    albumRequest!.addAssets(enumeration)
                }
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
