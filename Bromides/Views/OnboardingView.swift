//
//  OnboardingView.swift
//  Bromides
//
//  Created by シン・ジャスティン on 2025/03/22.
//

import Komponents
import SwiftUI

struct OnboardingView: View {
    @AppStorage(wrappedValue: .grid, "DisplayMode", store: defaults) var displayMode: DisplayMode

    var body: some View {
        NavigationStack {
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
                } header: {
                    ListSectionHeader(text: "Onboarding.Title")
                }
                Section {
                    Picker(selection: $displayMode) {
                        Text("Settings.DisplayMode.Grid")
                            .tag(DisplayMode.grid)
                        Text("Settings.DisplayMode.List")
                            .tag(DisplayMode.list)
                    } label: {
                        Text("Settings.DisplayMode")
                    }
                } header: {
                    ListSectionHeader(text: "Settings.Title")
                }
                Section {
                    Link(destination: URL(string: "https://github.com/katagaki/Bromides")!) {
                        HStack {
                            ListRow(image: "GitHub",
                                    title: "Settings.GitHub",
                                    subtitle: "katagaki/Bromides",
                                    includeSpacer: true)
                            Image(systemName: "safari")
                                .opacity(0.5)
                        }
                        .foregroundColor(.primary)
                    }
                }
            }
            .listSectionSpacing(.compact)
            .scrollContentBackground(.hidden)
            .background(
                .linearGradient(
                    colors: [.backgroundGradientTop, .backgroundGradientBottom],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .navigationTitle("Bromides")
            .safeAreaInset(edge: .bottom, spacing: 0.0) {
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
                .buttonStyle(.borderedProminent)
                .clipShape(.capsule)
                .shadow(color: .black.opacity(0.3), radius: 4.0, y: 3.0)
                .padding()
            }
        }
    }
}

#Preview {
    OnboardingView()
}
