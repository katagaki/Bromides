//
//  SelectedCollections.swift
//  Bromides
//
//  Created by シン・ジャスティン on 2026/06/11.
//

import Photos

extension [PHAssetCollection] {
    func isSelected(_ collection: PHCollection) -> Bool {
        contains(where: { $0.localIdentifier == collection.localIdentifier })
    }

    mutating func toggle(_ collection: PHAssetCollection, allowingMultiple: Bool) {
        if let index = firstIndex(where: { $0.localIdentifier == collection.localIdentifier }) {
            remove(at: index)
        } else if allowingMultiple {
            append(collection)
        } else {
            self = [collection]
        }
    }
}
