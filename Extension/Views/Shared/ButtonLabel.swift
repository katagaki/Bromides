//
//  ButtonLabel.swift
//  Bromides
//
//  Created by シン・ジャスティン on 2025/03/23.
//

import SwiftUI

struct ButtonLabel: View {
    var title: LocalizedStringKey
    var icon: String

    init(_ title: LocalizedStringKey, icon: String) {
        self.title = title
        self.icon = icon
    }

    var body: some View {
        Label(title, systemImage: icon)
            .padding(.horizontal, 16.0)
            .padding(.vertical, 8.0)
            .frame(maxWidth: .infinity)
            .bold()
            .lineLimit(1)
    }
}
