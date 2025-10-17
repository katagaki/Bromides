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
    var selectedAlbumIdentifiers: Set<String> = []

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
    
    func toggleAlbumSelection(_ album: PHAssetCollection) {
        let identifier = album.localIdentifier
        if selectedAlbumIdentifiers.contains(identifier) {
            selectedAlbumIdentifiers.remove(identifier)
        } else {
            selectedAlbumIdentifiers.insert(identifier)
        }
    }
    
    func isAlbumSelected(_ album: PHAssetCollection) -> Bool {
        return selectedAlbumIdentifiers.contains(album.localIdentifier)
    }
    
    func removeAlbum(withIdentifier identifier: String) {
        selectedAlbumIdentifiers.remove(identifier)
    }
}
