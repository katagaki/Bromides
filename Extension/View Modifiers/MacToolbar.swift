//
//  MacToolbar.swift
//  Bromides
//
//  Created by シン・ジャスティン on 2025/08/24.
//

import SwiftUI

struct MacToolbar: ViewModifier {
    @Binding var navigator: Navigator

    @AppStorage(wrappedValue: Data(), "RecentAlbums", store: defaults) var recentAlbumsData: Data

    var recentAlbums: [String] {
        let recentAlbums: [String] = (try? JSONDecoder().decode(
            [String].self,
            from: recentAlbumsData
        )) ?? []
        return recentAlbums.reversed()
    }

    @FocusState.Binding var isSearchFieldFocused: Bool

    var hasSearchBar: Bool

    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .top, spacing: 0.0) {
                HStack(alignment: .center) {
                    Button(role: .cancel, action: close) {
                        Text("Shared.Cancel")
                            .frame(height: 32.0)
                            .padding(.horizontal, 8.0)
                            .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                    .glassEffect(.regular.interactive(), in: .capsule)
                    if !navigator.viewPath.isEmpty {
                        Button {
                            _ = navigator.viewPath.popLast()
                        } label: {
                            Image(systemName: "chevron.backward")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 14.0, height: 14.0)
                                .padding(10.0)
                                .contentShape(.rect)
                        }
                        .buttonStyle(.plain)
                        .glassEffect(.regular.interactive(), in: .circle)
                    }
                    Spacer()
                    if hasSearchBar {
                        TextField("Shared.AlbumOrFolderName", text: $navigator.debouncingSearchTerm)
                            .textFieldStyle(.plain)
                            .safeAreaInset(edge: .leading) {
                                Image(systemName: "magnifyingglass")
                                    .padding(.leading, 12.0)
                            }
                            .padding(.horizontal, 6.0)
                            .padding(.vertical, 8.0)
                            .frame(width: 200.0)
                            .focused($isSearchFieldFocused)
                            .onTapGesture {
                                isSearchFieldFocused = true
                            }
                            .textInputSuggestions {
                                if navigator.debouncingSearchTerm.trimmingCharacters(in: .whitespaces) == "" {
                                    ForEach(recentAlbums, id: \.self) { albumName in
                                        Text(albumName)
                                            .font(.body)
                                            .textInputCompletion(albumName)
                                    }
                                }
                            }
                            .glassEffect(.regular.interactive(), in: .capsule)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 32.0, maxHeight: 32.0)
                .padding(8.0)
                .background(Material.bar)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .frame(height: 1.0)
                        .foregroundColor(.primary.opacity(0.2))
                        .ignoresSafeArea(edges: [.leading, .trailing])
                }
            }
    }
}

extension View {
    func toolbarForMac(
        navigator: Binding<Navigator>,
        isSearchFieldFocused: FocusState<Bool>.Binding,
        hasSearchBar: Bool = true
    ) -> some View {
        self.modifier(MacToolbar(
            navigator: navigator,
            isSearchFieldFocused: isSearchFieldFocused,
            hasSearchBar: hasSearchBar
        ))
    }
}
