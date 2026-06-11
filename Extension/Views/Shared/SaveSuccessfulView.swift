//
//  SaveSuccessfulView.swift
//  Bromides
//
//  Created by シン・ジャスティン on 2025/04/05.
//

import Photos
import SwiftUI

struct SaveSuccessfulView: View {
    var selectedCollections: [PHAssetCollection]

    init(_ selectedCollections: [PHAssetCollection] = []) {
        self.selectedCollections = selectedCollections
    }

    var body: some View {
        VStack(alignment: .center, spacing: 16.0) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 48.0, height: 48.0)
                .symbolRenderingMode(.multicolor)
            Group {
                switch selectedCollections.count {
                case 0:
                    Text("Message.Save.Library")
                case 1:
                    Text("""
Message.Save.\(selectedCollections[0].localizedTitle ?? NSLocalizedString("Shared.Album", comment: ""))
""")
                default:
                    Text("Message.Save.Multiple.\(selectedCollections.count)")
                }
            }
            .bold()
        }
    }
}
