//
//  App.swift
//  Bromides
//
//  Created by シン・ジャスティン on 2025/03/22.
//

import SwiftUI

@main
struct BromidesApp: App {
    var body: some Scene {
        WindowGroup {
            #if os(macOS)
            MacOnboardingView()
                .frame(width: 600.0, height: 400.0)
                .onAppear {
                    NSWindow.allowsAutomaticWindowTabbing = false
                }
            #else
            OnboardingView()
            #endif
        }
        #if os(macOS)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
        #endif
    }
}
