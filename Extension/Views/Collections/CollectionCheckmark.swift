//
//  CollectionCheckmark.swift
//  Bromides
//
//  Created by シン・ジャスティン on 2025/04/05.
//

import SwiftUI

struct CollectionCheckmark: View {
    var circumference: CGFloat
    var lineWidth: CGFloat

    var body: some View {
        ZStack(alignment: .center) {
            #if os(macOS)
            Color(nsColor: .windowBackgroundColor).opacity(0.3)
            #else
            Color(uiColor: .systemBackground).opacity(0.3)
            #endif
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .symbolRenderingMode(.multicolor)
                .frame(width: circumference, height: circumference)
                .overlay {
                    Circle()
                        .stroke(.white, lineWidth: lineWidth)
                }
        }
    }
}
