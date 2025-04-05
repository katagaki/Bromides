//
//  Navigator.swift
//  Bromides
//
//  Created by シン・ジャスティン on 2025/04/05.
//

import Foundation
import Observation

@Observable
class Navigator {
    var viewPath: [Collection] = []
    var searchTerm: String = ""

    func isSearching() -> Bool {
        if let lastViewPath = viewPath.last {
            return lastViewPath == .search
        }
        return false
    }

    func startSearching() {
        if !viewPath.contains(.search) {
            viewPath.append(.search)
        }
    }

    func stopSearching() {
        if let searchViewPath = viewPath.firstIndex(of: .search) {
            viewPath.remove(
                atOffsets: IndexSet(
                    searchViewPath...(viewPath.count - 1)
                )
            )
        }
    }
}
