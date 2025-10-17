//
//  Mac.swift
//  Bromides
//
//  Created by シン・ジャスティン on 2025/05/10.
//

import Komponents
import SwiftUI

extension ShareView {
    @ViewBuilder func macView(previewImage: XPImage) -> some View {
        VStack(alignment: .leading, spacing: 0.0) {
            if isPhotoSaveSuccessful {
                SaveSuccessfulView(navigator)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ZStack(alignment: .center) {
                    if isPhotosAuthorizationComplete {
                        if isPhotosAuthorizationDenied {
                            noAccessView()
                        } else {
                            CollectionsStack($navigator, saveAction: save)
                        }
                    } else {
                        ProgressView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .layoutPriority(0)
            }
        }
    }
}
