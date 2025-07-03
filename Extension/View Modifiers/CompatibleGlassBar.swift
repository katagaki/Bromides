//
//  GlassEffect.swift
//  Bromides
//
//  Created by シン・ジャスティン on 2025/06/15.
//

import Komponents
import SwiftUI

struct BottomBarAccessory: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .glassEffect(.regular, in: .rect(cornerRadius: 22.0))
        } else {
            BarAccessory(placement: .bottom) {
                content
            }
        }
    }
}

extension View {
    func wrapInBottomBarAccessory() -> some View {
        self.modifier(BottomBarAccessory())
    }
}
