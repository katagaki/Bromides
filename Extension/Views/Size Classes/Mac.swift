//
//  Mac.swift
//  Bromides
//
//  Created by シン・ジャスティン on 2025/05/10.
//

import Komponents
import SwiftUI

extension ShareView {
    @ViewBuilder func macView(previewImage: UIImage) -> some View {
        VStack(alignment: .leading, spacing: 0.0) {
            if isPhotoSaveSuccessful {
                SaveSuccessfulView(selectedCollection)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ZStack(alignment: .center) {
                    if isPhotosAuthorizationComplete {
                        if isPhotosAuthorizationDenied {
                            ContentUnavailableView("Error.PhotosAccess", systemImage: "xmark.circle.fill")
                                .symbolRenderingMode(.multicolor)
                        } else {
                            CollectionsStack($navigator, selection: $selectedCollection)
                                .safeAreaInset(edge: .bottom, spacing: 0.0) {
                                    BarAccessory(placement: .bottom, isBackgroundSolid: false) {
                                        VStack(spacing: 16.0) {
                                            SearchField($navigator.searchTerm)
                                            HStack {
                                                Spacer()
                                                closeButton()
                                                saveButton()
                                            }
                                            .padding([.leading, .trailing, .bottom])
                                        }
                                    }
                                }
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
