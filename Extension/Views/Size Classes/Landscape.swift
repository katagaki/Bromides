//
//  Landscape.swift
//  Bromides
//
//  Created by シン・ジャスティン on 2025/05/10.
//

import Komponents
import SwiftUI

extension ShareView {
    @ViewBuilder func landscapeView(previewImage: XPImage) -> some View {
        HStack(alignment: .top, spacing: 0.0) {
            VStack(alignment: .leading, spacing: 0.0) {
                Spacer()
                ImagePreview(previewImage)
                    .frame(maxWidth: .infinity, minHeight: 160.0, maxHeight: .infinity)
                    .matchedGeometryEffect(id: "@$_bromidesPrivateIdentifier_preview", in: namespace)
                if isPhotoSaveSuccessful {
                    SaveSuccessfulView(navigator)
                        .frame(maxWidth: .infinity)
                        .padding()
                    Spacer()
                } else {
                    Spacer()
                }
            }
            if !isPhotoSaveSuccessful {
                ZStack(alignment: .center) {
                    if isPhotosAuthorizationComplete {
                        if isPhotosAuthorizationDenied {
                            noAccessView()
                        } else {
                            CollectionsStack($navigator, saveAction: save)
                                .matchedGeometryEffect(
                                    id: "@$_bromidesPrivateIdentifier_albumBrowser",
                                    in: namespace
                                )
                        }
                    } else {
                        ProgressView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                Divider()
                    .ignoresSafeArea(.all, edges: .vertical)
            }
        }
    }
}
