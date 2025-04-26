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
    @AppStorage(wrappedValue: Data(), "RecentAlbums", store: defaults) var recentAlbumsData: Data
    @State var recentAlbums: [String] = []

    init(_ searchTerm: Binding<String>) {
        self._searchTerm = searchTerm
    }

    var body: some View {
        UITextField.appearance().clearButtonMode = .whileEditing
        return VStack(spacing: 0.0) {
            if !recentAlbums.isEmpty {
                ScrollView(.horizontal) {
                    HStack(spacing: 8.0) {
                        ForEach(recentAlbums, id: \.self) { albumName in
                            Button {
                                searchTerm = albumName
                            } label: {
                                Text(albumName)
                                    .font(.subheadline)
                                    .padding(.horizontal, 8.0)
                                    .padding(.vertical, 4.0)
                                    .lineLimit(1)
                                    .background(.background.opacity(0.3))
                            }
                            .clipShape(.capsule)
                            .overlay(
                                Capsule()
                                    .stroke(.accent, lineWidth: 1)
                                    .opacity(0.5)
                            )
                        }
                    }
                    .padding([.horizontal, .bottom])
                    .padding(.top, 1.0)
                }
                .scrollIndicators(.hidden)
            }
            TextField(
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
            .padding(.horizontal)
        }
        .padding(.top)
        .onAppear {
            let recentAlbums: [String] = (try? JSONDecoder().decode(
                [String].self,
                from: recentAlbumsData
            )) ?? []
            self.recentAlbums = recentAlbums.reversed()
        }
    }
}
