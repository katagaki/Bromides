//
//  SaveSuccessfulView.swift
//  Bromides
//
//  Created by シン・ジャスティン on 2025/04/05.
//

import Photos
import SwiftUI

struct SaveSuccessfulView: View {
    var selectedCollection: PHAssetCollection?

    init(_ selectedCollection: PHAssetCollection? = nil) {
        self.selectedCollection = selectedCollection
    }

    var body: some View {
        VStack(alignment: .center, spacing: 16.0) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 48.0, height: 48.0)
                .symbolRenderingMode(.multicolor)
            Text("""
Message.Save.\(selectedCollection?.localizedTitle ?? NSLocalizedString("Shared.Album", comment: ""))
""")
                .bold()
        }
    }
}
