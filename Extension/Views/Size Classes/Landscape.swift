//
//  Landscape.swift
//  Bromides
//
//  Created by シン・ジャスティン on 2025/05/10.
//

import Komponents
import SwiftUI

extension ShareView {
    @ViewBuilder func landscapeView(previewImage: UIImage) -> some View {
        HStack(alignment: .top, spacing: 0.0) {
            if !isPhotoSaveSuccessful {
                ZStack(alignment: .center) {
                    if isPhotosAuthorizationComplete {
                        if isPhotosAuthorizationDenied {
                            ContentUnavailableView("Error.PhotosAccess", systemImage: "xmark.circle.fill")
                                .symbolRenderingMode(.multicolor)
                        } else {
                            CollectionsStack($navigator, selection: $selectedCollection)
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
            VStack(alignment: .leading, spacing: 0.0) {
                Spacer()
                ImagePreview(previewImage)
                    .frame(maxWidth: .infinity, minHeight: 160.0, maxHeight: .infinity)
                    .matchedGeometryEffect(id: "@$_bromidesPrivateIdentifier_preview", in: namespace)
                if isPhotoSaveSuccessful {
                    SaveSuccessfulView(selectedCollection)
                        .frame(maxWidth: .infinity)
                        .padding()
                    Spacer()
                } else {
                    Spacer()
                    VStack(spacing: 12.0) {
                        saveButton()
                            .matchedGeometryEffect(id: "@$_bromidesPrivateIdentifier_save", in: namespace)
                        closeButton()
                            .matchedGeometryEffect(id: "@$_bromidesPrivateIdentifier_close", in: namespace)
                    }
                    .padding()
                }
            }
        }
    }
}
