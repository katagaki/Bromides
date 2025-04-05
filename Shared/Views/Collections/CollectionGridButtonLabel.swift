//
//  CollectionButtonLabel.swift
//  Bromides
//
//  Created by シン・ジャスティン on 2025/03/23.
//

import Photos
import SwiftUI

struct CollectionButtonLabel: View {
    var collection: Collection
    var mode: DisplayMode
    var isSelected: (() -> Bool)?

    var body: some View {
        Group {
            switch mode {
            case .grid:
                HStack(alignment: .top) {
                    VStack(alignment: .center, spacing: 6.0) {
                        CollectionCover(collection, iconSize: 32.0)
                            .frame(width: 72.0, height: 72.0)
                            .overlay {
                                if let isSelected, isSelected() {
                                    CollectionCheckmark(circumference: 28.0, lineWidth: 2.0)
                                }
                            }
                            .compositingGroup()
                            .clipShape(.rect(cornerRadius: 6.0))
                            .shadow(radius: 3.0, y: 2.0)
                        Text(collection.title)
                            .lineLimit(1)
                            .font(.caption)
                    }
                }
            case .list:
                HStack(alignment: .center, spacing: 16.0) {
                    CollectionCover(collection, iconSize: 24.0)
                        .frame(width: 38.0, height: 38.0)
                        .overlay {
                            if let isSelected, isSelected() {
                                CollectionCheckmark(circumference: 18.0, lineWidth: 1.5)
                            }
                        }
                        .compositingGroup()
                        .clipShape(.rect(cornerRadius: 6.0))
                        .shadow(radius: 2.0, y: 1.5)
                    Text(collection.title)
                        .font(.body)
                        .layoutPriority(0)
                }
            case .panels:
                HStack(alignment: .center, spacing: 10.0) {
                    CollectionCover(collection, iconSize: 24.0)
                        .frame(width: 46.0, height: 46.0)
                        .overlay {
                            if let isSelected, isSelected() {
                                CollectionCheckmark(circumference: 22.0, lineWidth: 1.5)
                            }
                        }
                    Text(collection.title)
                        .font(.subheadline)
                        .layoutPriority(0)
                }
                .frame(maxWidth: .infinity, maxHeight: 46.0, alignment: .leading)
                .background(Material.ultraThin)
                .clipShape(.rect(cornerRadius: 10.0))
                .shadow(color: .black.opacity(0.2), radius: 5.0, y: 4.0)
            }
        }
    }
}
