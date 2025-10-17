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
    
    var body: some View {
        if !navigator.selectedAlbumIdentifiers.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8.0) {
                    ForEach(Array(navigator.selectedAlbumIdentifiers), id: \.self) { identifier in
                        if let album = PhotosLibrary.albumsFromIdentifiers([identifier]).first,
                           let albumName = album.localizedTitle {
                            HStack(spacing: 4.0) {
                                Text(albumName)
                                    .font(.subheadline)
                                    .lineLimit(1)
                                Button {
                                    withAnimation(.smooth.speed(2.0)) {
                                        navigator.removeAlbum(withIdentifier: identifier)
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
                }
                .padding(.horizontal)
            }
            .frame(height: 36.0)
        }
    }
}
