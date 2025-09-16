//
//  Navigator.swift
//  Bromides
//
//  Created by シン・ジャスティン on 2025/04/05.
//

import Foundation
import Observation

@Observable
class Navigator: @unchecked Sendable {
    var viewPath: [Collection] = []
    var searchTerm: String = ""
    var debouncingSearchTerm: String = ""

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
}
