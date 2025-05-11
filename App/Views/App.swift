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
            #if !targetEnvironment(macCatalyst)
            OnboardingView()
            #else
            MacOnboardingView()
                .frame(width: 600.0, height: 400.0)
            #endif
        }
        #if targetEnvironment(macCatalyst)
        .windowResizability(.contentSize)
        .commandsRemoved()
        #endif
    }
}
