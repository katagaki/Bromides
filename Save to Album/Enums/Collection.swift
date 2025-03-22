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

    var id: String {
        switch self {
        case .album(let collection):
            return collection.localIdentifier
        case .folder(let collection):
            return collection.localIdentifier
        }
    }

    var title: String {
        switch self {
        case .album(let collection):
            return collection.localizedTitle ?? "Album"
        case .folder(let collection):
            return collection.localizedTitle ?? "Folder"
        }
    }
}
