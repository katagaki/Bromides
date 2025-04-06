//
//  Collection.swift
//  Bromides
//
//  Created by シン・ジャスティン on 2025/03/23.
//

import Photos

enum Collection: Identifiable, Hashable {
    case album(collection: PHCollection)
    case folder(collection: PHCollection)
    case search

    var id: String {
        switch self {
        case .album(let collection):
            return collection.localIdentifier
        case .folder(let collection):
            return collection.localIdentifier
        case .search:
            return "@$_bromidesPrivateIdentifier_search"
        }
    }

    var title: String {
        switch self {
        case .album(let collection):
            return collection.localizedTitle ?? NSLocalizedString("Shared.Album", comment: "")
        case .folder(let collection):
            return collection.localizedTitle ?? NSLocalizedString("Shared.Folder", comment: "")
        case .search:
            return NSLocalizedString("Shared.SearchResults", comment: "")
        }
    }
}
