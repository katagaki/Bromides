//
//  ImagePreview.swift
//  Bromides
//
//  Created by シン・ジャスティン on 2025/03/23.
//

import SwiftUI
import UIKit

struct ImagePreview: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    var uiImage: UIImage

    init(_ uiImage: UIImage) {
        self.uiImage = uiImage
    }

    var body: some View {
        VStack(alignment: .center) {
            Image(uiImage: uiImage)
                .resizable()
                .clipShape(.rect(cornerRadius: 6.0))
                .aspectRatio(contentMode: .fit)
                .shadow(radius: 3.0, y: 2.0)
                .padding()
        }
        .frame(
            maxWidth: .infinity,
            minHeight: (verticalSizeClass == .regular && horizontalSizeClass == .compact ? 160.0 : 90.0),
            maxHeight: (verticalSizeClass == .regular && horizontalSizeClass == .compact ? 160.0 : 90.0)
        )
    }
}
