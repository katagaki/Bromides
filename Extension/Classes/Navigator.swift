//
//  Navigator.swift
//  Bromides
//
//  Created by シン・ジャスティン on 2025/04/05.
//

import Foundation
import Observation
import Photos

@Observable
class Navigator: @unchecked Sendable {
    var viewPath: [Collection] = []
    var searchTerm: String = ""
    var debouncingSearchTerm: String = ""
    var selectedAlbumIdentifiers: [String] = []

    @ObservationIgnored var timer: Timer?

    var isSearching: Bool {
        return searchTerm.trimmingCharacters(in: .whitespaces) != ""
    }

    func debounceSearch() {
        if debouncingSearchTerm.trimmingCharacters(in: .whitespaces) == "" {
            searchTerm = ""
        } else if debouncingSearchTerm == searchTerm {
            return
        } else {
            timer?.invalidate()
            timer = Timer.scheduledTimer(
                withTimeInterval: 0.2, repeats: false
            ) { _ in
                self.searchTerm = self.debouncingSearchTerm
            }
        }
    }
    
    func toggleAlbumSelection(_ album: PHAssetCollection, allowMultiple: Bool = true) {
        let identifier = album.localIdentifier
        if let index = selectedAlbumIdentifiers.firstIndex(of: identifier) {
            selectedAlbumIdentifiers.remove(at: index)
        } else {
            if !allowMultiple {
                // Clear all selections before adding new one
                selectedAlbumIdentifiers.removeAll()
            }
            selectedAlbumIdentifiers.append(identifier)
        }
    }
    
    func selectAlbum(_ album: PHAssetCollection, allowMultiple: Bool = true) {
        let identifier = album.localIdentifier
        if !allowMultiple {
            // Clear all selections before adding new one
            selectedAlbumIdentifiers.removeAll()
        }
        if !selectedAlbumIdentifiers.contains(identifier) {
            selectedAlbumIdentifiers.append(identifier)
        }
    }
    
    func isAlbumSelected(_ album: PHAssetCollection) -> Bool {
        return selectedAlbumIdentifiers.contains(album.localIdentifier)
    }
    
    func removeAlbum(withIdentifier identifier: String) {
        if let index = selectedAlbumIdentifiers.firstIndex(of: identifier) {
            selectedAlbumIdentifiers.remove(at: index)
        }
    }
}
