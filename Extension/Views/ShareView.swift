//
//  ShareView.swift
//  Bromides
//
//  Created by シン・ジャスティン on 2025/03/22.
//

import Komponents
import Photos
import SwiftData
import SwiftUI

struct ShareView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    @State var navigator: Navigator = Navigator()
    var imageData: Data?
    var previewImage: UIImage?

    @State var selectedCollection: PHAssetCollection?
    @State var isPhotoSaving: Bool = false
    @State var isPhotoSaveSuccessful: Bool = false
    @State var isPhotoSaveFailed: Bool = false
    @State var isPhotosAuthorizationComplete: Bool = false
    @State var isPhotosAuthorizationDenied: Bool = false

    init(items: [Any?]) {
        guard let item = items.first else { return }
        if let url = item as? URL, let imageData = try? Data(contentsOf: url) {
            self.imageData = imageData
        } else if let image = item as? UIImage {
            if let pngData = image.pngData() {
                self.imageData = pngData
            } else if let jpegData = image.jpegData(compressionQuality: 1.0) {
                self.imageData = jpegData
            } else if let heicData = image.heicData() {
                self.imageData = heicData
            }
        } else if let data = item as? Data {
            self.imageData = data
        }
        guard let imageData = self.imageData else { return }
        guard let uiImage = UIImage(data: imageData)?
            .preparingThumbnail(of: .init(width: 600.0, height: 600.0)) else { return }
        self.previewImage = uiImage
    }

    var body: some View {
        if imageData != nil, let previewImage {
            Group {
                if verticalSizeClass == .regular && horizontalSizeClass == .compact {
                    // Portrait
                    VStack(alignment: .leading, spacing: 0.0) {
                        ImagePreview(previewImage)
                            .frame(maxWidth: .infinity, minHeight: 160.0, maxHeight: 160.0)
                            .id("@$_bromidesPrivateIdentifier_preview")
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
                                            .safeAreaInset(edge: .bottom, spacing: 0.0) {
                                                BarAccessory(placement: .bottom, isBackgroundSolid: false) {
                                                    VStack(spacing: 16.0) {
                                                        SearchField($navigator.searchTerm)
                                                        HStack {
                                                            saveButton()
                                                                .id("@$_bromidesPrivateIdentifier_save")
                                                            closeButton()
                                                                .id("@$_bromidesPrivateIdentifier_close")
                                                        }
                                                    }
                                                    .padding()
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
                } else {
                    // Landscape
                    HStack(alignment: .top, spacing: 0.0) {
                        if !isPhotoSaveSuccessful {
                            ZStack(alignment: .center) {
                                if isPhotosAuthorizationComplete {
                                    if isPhotosAuthorizationDenied {
                                        ContentUnavailableView("Error.PhotosAccess", systemImage: "xmark.circle.fill")
                                            .symbolRenderingMode(.multicolor)
                                    } else {
                                        CollectionsStack($navigator, selection: $selectedCollection)
                                            .id("@$_bromidesPrivateIdentifier_albumBrowser")
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
                                .id("@$_bromidesPrivateIdentifier_preview")
                            if isPhotoSaveSuccessful {
                                SaveSuccessfulView(selectedCollection)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                Spacer()
                            } else {
                                Spacer()
                                HStack {
                                    saveButton()
                                        .id("@$_bromidesPrivateIdentifier_save")
                                    closeButton()
                                        .id("@$_bromidesPrivateIdentifier_close")
                                }
                                .padding()
                            }
                        }
                    }
                }
            }
            .task {
                let status = await PhotosLibrary.requestAuthorization()
                switch status {
                case .authorized:
                    isPhotosAuthorizationDenied = false
                default:
                    isPhotosAuthorizationDenied = true
                }
                isPhotosAuthorizationComplete = true
            }
            .alert("Error.SaveFailed", isPresented: $isPhotoSaveFailed) {
                Button("Shared.Dismiss", action: {})
            }
        } else {
            VStack(alignment: .leading, spacing: 0.0) {
                Spacer()
                ContentUnavailableView("Error.NoImage", systemImage: "photo.badge.exclamationmark.fill")
                    .padding()
                Spacer()
                Divider()
                closeButton(isProminent: true)
                    .padding()
            }
        }
    }

    @ViewBuilder func saveButton() -> some View {
        Button {
            save()
        } label: {
            ButtonLabel("Shared.Save", icon: "square.and.arrow.down")
        }
        .buttonStyle(.borderedProminent)
        .disabled(selectedCollection == nil || isPhotoSaving)
        .clipShape(.capsule)
    }

    @ViewBuilder func closeButton(isProminent: Bool = false) -> some View {
        let button = Button {
            close()
        } label: {
            ButtonLabel("Shared.Close", icon: "xmark")
        }
        Group {
            if isProminent {
                button
                    .buttonStyle(.borderedProminent)
            } else {
                button
                    .buttonStyle(.bordered)
            }
        }
        .clipShape(.capsule)
        .disabled(isPhotoSaving)
    }

    func close() {
        NotificationCenter.default.post(name: NSNotification.Name("close"), object: nil)
    }

    func save() {
        if let imageData, let selectedCollection {
            isPhotoSaving = true
            Task {
                let isPhotoSaved: Bool = await PhotosLibrary.saveImage(
                    data: imageData,
                    to: selectedCollection
                )
                if isPhotoSaved {
                    withAnimation(.smooth.speed(2.0)) {
                        isPhotoSaveSuccessful = true
                    } completion: {
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            close()
                        }
                    }
                } else {
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                    isPhotoSaving = false
                    isPhotoSaveFailed = true
                }
            }
        } else {
            isPhotoSaveFailed = true
        }
    }
}
