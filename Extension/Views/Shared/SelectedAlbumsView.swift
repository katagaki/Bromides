//
//  SelectedAlbumsView.swift
//  Bromides
//
//  Created by Copilot
//

import Photos
import SwiftUI

struct SelectedAlbumsView: View {
    @Binding var navigator: Navigator
    
    @State private var selectedAlbums: [(identifier: String, name: String)] = []
    
    var body: some View {
        if !navigator.selectedAlbumIdentifiers.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8.0) {
                    ForEach(selectedAlbums, id: \.identifier) { album in
                        HStack(spacing: 4.0) {
                            Text(album.name)
                                .font(.subheadline)
                                .lineLimit(1)
                            Button {
                                withAnimation(.smooth.speed(2.0)) {
                                    navigator.removeAlbum(withIdentifier: album.identifier)
                                }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 10.0)
                        .padding(.vertical, 6.0)
                        .background(Material.thin)
                        .clipShape(.capsule)
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 36.0)
            .task {
                updateSelectedAlbums()
            }
            .onChange(of: navigator.selectedAlbumIdentifiers) { _, _ in
                updateSelectedAlbums()
            }
        }
    }
    
    private func updateSelectedAlbums() {
        // Maintain the order from selectedAlbumIdentifiers
        let albums = PhotosLibrary.albumsFromIdentifiers(navigator.selectedAlbumIdentifiers)
        // Create a dictionary for quick lookup
        var albumDict: [String: String] = [:]
        for album in albums {
            if let name = album.localizedTitle {
                albumDict[album.localIdentifier] = name
            }
        }
        // Build the array in the correct order
        selectedAlbums = navigator.selectedAlbumIdentifiers.compactMap { identifier in
            guard let name = albumDict[identifier] else { return nil }
            return (identifier: identifier, name: name)
        }
    }
}
