//
//  ImagePreview.swift
//  Bromides
//
//  Created by シン・ジャスティン on 2025/03/23.
//

import SwiftUI
import UIKit

struct ImagePreview: View {
    var uiImage: UIImage

    var body: some View {
        VStack(alignment: .center) {
            Image(uiImage: uiImage)
                .resizable()
                .clipShape(.rect(cornerRadius: 6.0))
                .aspectRatio(contentMode: .fit)
                .shadow(radius: 3.0, y: 2.0)
                .padding()
        }
        .frame(maxWidth: .infinity, minHeight: 180.0, maxHeight: 180.0)
    }
}
