//
//  MacOnboardingView.swift
//  Bromides
//
//  Created by シン・ジャスティン on 2025/05/10.
//

import Komponents
import SwiftUI

struct MacOnboardingView: View {
    @AppStorage(wrappedValue: .grid, "DisplayMode", store: defaults) var displayMode: DisplayMode
    @AppStorage(wrappedValue: true, "SaveRecentAlbums", store: defaults) var saveRecentAlbums: Bool
    @AppStorage(wrappedValue: true, "ShowSaveAnimation", store: defaults) var showSaveAnimation: Bool
    @AppStorage(wrappedValue: false, "AutoSelectSearch", store: defaults) var autoSelectFirstSearchResult: Bool
    @AppStorage(wrappedValue: false, "AutoOpenKeyboard", store: defaults) var autoOpenKeyboard: Bool
    @AppStorage(wrappedValue: Data(), "RecentAlbums", store: defaults) var recentAlbumsData: Data

    var body: some View {
        TabView {
            Tab("Onboarding.Title", systemImage: "questionmark.circle") {
                List {
                    Section {
                        VStack(alignment: .center, spacing: 10.0) {
                            Text("Onboarding.1.\(Image(systemName: "square.and.arrow.up"))")
                                .multilineTextAlignment(.center)
                            Image(systemName: "arrow.down")
                                .font(.title2)
                            Image(.appIconMasked)
                                .resizable()
                                .frame(width: 64.0, height: 64.0)
                                .clipShape(.rect(cornerRadius: 14.0))
                                .shadow(radius: 2.0, y: 2.0)
                            Text("Onboarding.2")
                                .multilineTextAlignment(.center)
                            Image(systemName: "arrow.down")
                                .font(.title2)
                            Text("Onboarding.3")
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .listRowBackground(Color.clear)
                    }
                    .scrollContentBackground(.hidden)
                    Section {
                        ShareLink(
                            item: Image(uiImage: UIImage(resource: .sample)),
                            preview: SharePreview(
                                "Shared.SamplePhoto",
                                image: Image(uiImage: UIImage(resource: .sample))
                            )
                        ) {
                            Label("Onboarding.Share", systemImage: "square.and.arrow.up")
                                .padding(.horizontal, 16.0)
                                .padding(.vertical, 8.0)
                                .frame(maxWidth: .infinity)
                                .bold()
                        }
                        .padding(2.0)
                    }
                }
            }
            Tab("Settings.Title", systemImage: "gear") {
                VStack(alignment: .leading, spacing: 8.0) {
                    Picker(selection: $displayMode) {
                        Text("Settings.DisplayMode.Grid")
                            .tag(DisplayMode.grid)
                        Text("Settings.DisplayMode.List")
                            .tag(DisplayMode.list)
                        Text("Settings.DisplayMode.Panels")
                            .tag(DisplayMode.panels)
                    } label: {
                        Text("Settings.DisplayMode")
                    }
                    Toggle("Settings.EnableSaveAnimation", isOn: $showSaveAnimation)
                    Toggle("Settings.SaveRecents", isOn: $saveRecentAlbums)
                    Toggle("Settings.AutoOpenKeyboard", isOn: $autoOpenKeyboard)
                    Toggle("Settings.AutoSelectFirstSearchResult", isOn: $autoSelectFirstSearchResult)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding()
            }
            Tab("About.Title", systemImage: "info.circle") {
                VStack(alignment: .center, spacing: 8.0) {
                    Text("About.Developer")
                        .font(.title3)
                    Divider()
                    Text("About.SourceCode")
                    Link(destination: URL(string: "https://github.com/katagaki/Bromides")!) {
                        Label("katagaki/Bromides", image: "GitHub")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding()
            }
        }
        .onChange(of: saveRecentAlbums) { oldValue, newValue in
            if oldValue && !newValue {
                recentAlbumsData = Data()
            }
        }
    }
}

#Preview(traits: .fixedLayout(width: 600, height: 500)) {
    MacOnboardingView()
}
