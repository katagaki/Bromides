//
//  PortraitShareView.swift
//  Bromides
//
//  Created by シン・ジャスティン on 2025/05/10.
//

import Komponents
import SwiftUI

extension ShareView {
    @ViewBuilder func portraitView(previewImage: UIImage) -> some View {
        VStack(alignment: .leading, spacing: 0.0) {
            ImagePreview(previewImage)
                .frame(maxWidth: .infinity, minHeight: 160.0, maxHeight: 160.0)
                .matchedGeometryEffect(id: "@$_bromidesPrivateIdentifier_preview", in: namespace)
            if isPhotoSaveSuccessful {
                SaveSuccessfulView(selectedCollection)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                Divider()
                    .ignoresSafeArea(.all, edges: .horizontal)
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
                                .safeAreaInset(edge: .bottom, spacing: 0.0) {
                                    BarAccessory(placement: .bottom, isBackgroundSolid: false) {
                                        VStack(spacing: 16.0) {
                                            SearchField($navigator.searchTerm)
                                            HStack {
                                                saveButton()
                                                    .matchedGeometryEffect(
                                                        id: "@$_bromidesPrivateIdentifier_save",
                                                        in: namespace
                                                    )
                                                closeButton()
                                                    .matchedGeometryEffect(
                                                        id: "@$_bromidesPrivateIdentifier_close",
                                                        in: namespace
                                                    )
                                            }
                                            .padding([.leading, .trailing, .bottom])
                                        }
                                    }
                                }
                                .id("@$_bromidesPrivateIdentifier_albumBrowser")
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
