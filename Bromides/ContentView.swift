//
//  ContentView.swift
//  Bromides
//
//  Created by シン・ジャスティン on 2025/03/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16.0) {
                VStack(alignment: .center, spacing: 16.0) {
                    Text("Onboarding.1.\(Image(systemName: "square.and.arrow.up"))")
                    Image(systemName: "arrow.down")
                        .font(.title2)
                    Image(.appIconMasked)
                        .resizable()
                        .frame(width: 64.0, height: 64.0)
                        .clipShape(.rect(cornerRadius: 14.0))
                        .shadow(radius: 2.0, y: 2.0)
                    Text("Onboarding.2")
                    Image(systemName: "arrow.down")
                        .font(.title2)
                    Text("Onboarding.3")
                }
                .frame(maxWidth: .infinity)
                Spacer()
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
            }
            .padding()
            .navigationTitle("Bromides")
        }
    }
}
