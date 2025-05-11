//
//  SearchField.swift
//  Bromides
//
//  Created by シン・ジャスティン on 2025/03/30.
//

import SwiftUI

struct SearchField: View {
    @AppStorage(wrappedValue: false, "AutoOpenKeyboard", store: defaults) var autoOpenKeyboard: Bool
    @AppStorage(wrappedValue: Data(), "RecentAlbums", store: defaults) var recentAlbumsData: Data

    @Binding var searchTerm: String
    @FocusState private var isFocused: Bool
    @State var shouldAllowFocus: Bool
    @State var recentAlbums: [String] = []

    init(_ searchTerm: Binding<String>, shouldAllowFocus: Bool = true) {
        self._searchTerm = searchTerm
        self.shouldAllowFocus = shouldAllowFocus
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
                                    .padding(.horizontal, 10.0)
                                    .padding(.vertical, 6.0)
                                    .lineLimit(1)
                                    .background(.ultraThinMaterial)
                                    .foregroundStyle(.primary.opacity(0.9))
                            }
                            .buttonStyle(.plain)
                            .clipShape(.capsule)
                            .overlay(
                                Capsule()
                                    .stroke(.primary, lineWidth: 1)
                                    .opacity(0.1)
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
            #if targetEnvironment(macCatalyst)
            .focusEffectDisabled()
            #endif
            .padding(.horizontal, 10.0)
            .padding(.vertical, 12.0)
            .frame(maxWidth: .infinity)
            .background(Material.ultraThin)
            .focused($isFocused)
            .onTapGesture {
                if shouldAllowFocus {
                    isFocused = true
                }
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
            if shouldAllowFocus && autoOpenKeyboard {
                isFocused = true
            }
        }
    }
}
