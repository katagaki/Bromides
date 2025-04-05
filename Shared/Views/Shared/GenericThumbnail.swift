//
//  GenericThumbnail.swift
//  Bromides
//
//  Created by シン・ジャスティン on 2025/03/27.
//

import SwiftUI

struct GenericThumbnail: View {
    @Environment(\.colorScheme) var colorScheme
    var text: String
    var iconName: String
    var iconSize: CGFloat

    var body: some View {
        Rectangle()
            .fill(
                Color(from: text)
                    .gradient
            )
            .brightness(colorScheme == .dark ? -0.2 : 0.05)
            .saturation(1.1)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay {
                Image(systemName: iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize, alignment: .center)
                    .foregroundStyle(Color(from: text))
                    .brightness(colorScheme == .dark ? 0.0 : -0.15)
            }
    }
}
