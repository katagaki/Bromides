//
//  ContentView.swift
//  Bromides
//
//  Created by シン・ジャスティン on 2025/03/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16.0) {
            VStack(alignment: .leading, spacing: 0.0) {
                Text("Bromides")
                    .font(.largeTitle)
                    .bold()
                Text("Save photos to your albums without hassle.")
                    .font(.caption)
            }
            Divider()
            Text("To start using the Save to Album share extension, start sharing a photo from any app.")
            Divider()
            Spacer()
            ShareLink(
                item: Image(uiImage: UIImage(resource: .sample)),
                preview: SharePreview(
                    "Sample Photo",
                    image: Image(uiImage: UIImage(resource: .sample))
                )
            ) {
                Label("Try Bromides", systemImage: "square.and.arrow.up")
                    .padding(.horizontal, 16.0)
                    .padding(.vertical, 8.0)
                    .frame(maxWidth: .infinity)
                    .bold()
            }
            .buttonStyle(.borderedProminent)
            .clipShape(.capsule)
        }
        .padding()
    }
}
