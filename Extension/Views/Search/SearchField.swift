//
//  SearchField.swift
//  Bromides
//
//  Created by シン・ジャスティン on 2025/03/30.
//

import SwiftUI

struct SearchField: View {
    @Binding var searchTerm: String
    @FocusState private var isFocused: Bool

    init(_ searchTerm: Binding<String>) {
        self._searchTerm = searchTerm
    }

    var body: some View {
        UITextField.appearance().clearButtonMode = .whileEditing
        return TextField(
            "Shared.AlbumOrFolderName.\(Image(systemName: "magnifyingglass"))",
            text: $searchTerm
        )
        .padding(.horizontal, 10.0)
        .padding(.vertical, 12.0)
        .frame(maxWidth: .infinity)
        .background(Material.ultraThin)
        .focused($isFocused)
        .onTapGesture {
            isFocused = true
        }
        .clipShape(.rect(cornerRadius: 10.0))
        .shadow(color: .black.opacity(0.2), radius: 5.0, y: 3.0)
        .submitLabel(.search)
    }
}
