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
    var saveAction: (() -> Void)?
    var isSaveDisabled: Bool

    func body(content: Content) -> some View {
        content
            #if os(macOS)
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
                        Text(navigator.viewPath.last?.title ?? "")
                            .bold()
                    } else {
                        Text("ViewTitle.SelectAnAlbum")
                            .bold()
                    }
                    Spacer()
                    if hasSearchBar {
                        TextField("Shared.AlbumOrFolderName", text: $navigator.debouncingSearchTerm)
                            .textFieldStyle(.plain)
                            .safeAreaInset(edge: .leading) {
                                Image(systemName: "magnifyingglass")
                                    .padding(.leading, 6.0)
                                    .foregroundStyle(.secondary)
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
                    if let saveAction {
                        Button(role: .confirm, action: saveAction) {
                            Text("Shared.Save")
                                .frame(height: 32.0)
                                .padding(.horizontal, 8.0)
                                .contentShape(.rect)
                        }
                        .buttonStyle(.plain)
                        .frame(height: 32.0)
                        .glassEffect(.regular.interactive().tint(.accent), in: .capsule)
                        .accessibilityLabel(Text("Shared.Save"))
                        .disabled(isSaveDisabled)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 32.0, maxHeight: 32.0)
                .padding(8.0)
                .background(Material.ultraThin)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .frame(height: 1.0)
                        .foregroundColor(.primary.opacity(0.2))
                        .ignoresSafeArea(edges: [.leading, .trailing])
                }
            }
            #endif
    }
}

extension View {
    func toolbarForMac(
        navigator: Binding<Navigator>,
        isSearchFieldFocused: FocusState<Bool>.Binding,
        hasSearchBar: Bool = true,
        saveAction: (() -> Void)? = nil,
        isSaveDisabled: Bool = false
    ) -> some View {
        self.modifier(MacToolbar(
            navigator: navigator,
            isSearchFieldFocused: isSearchFieldFocused,
            hasSearchBar: hasSearchBar,
            saveAction: saveAction,
            isSaveDisabled: isSaveDisabled
        ))
    }
}
