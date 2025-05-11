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
    @AppStorage(wrappedValue: true, "SaveRecentAlbums", store: defaults) var saveRecentAlbums: Bool
    @AppStorage(wrappedValue: true, "ShowSaveAnimation", store: defaults) var showSaveAnimation: Bool
    @AppStorage(wrappedValue: Data(), "RecentAlbums", store: defaults) var recentAlbumsData: Data

    @State var navigator: Navigator = Navigator()
    var imageData: Data?
    var previewImage: UIImage?

    @State var selectedCollection: PHAssetCollection?
    @State var isPhotoSaving: Bool = false
    @State var isPhotoSaveSuccessful: Bool = false
    @State var isPhotoSaveFailed: Bool = false
    @State var isPhotosAuthorizationComplete: Bool = false
    @State var isPhotosAuthorizationDenied: Bool = false

    @Namespace var namespace

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
                #if !targetEnvironment(macCatalyst)
                if verticalSizeClass == .regular && horizontalSizeClass == .compact {
                    portraitView(previewImage: previewImage)
                } else {
                    landscapeView(previewImage: previewImage)
                }
                #else
                macView(previewImage: previewImage)
                #endif
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
            #if !targetEnvironment(macCatalyst)
            ButtonLabel("Shared.Save", icon: "square.and.arrow.down")
            #else
            Text("Shared.Save")
            #endif
        }
        #if targetEnvironment(macCatalyst)
        .controlSize(.large)
        #endif
        .buttonStyle(.borderedProminent)
        .disabled(selectedCollection == nil || isPhotoSaving)
        #if !targetEnvironment(macCatalyst)
        .clipShape(.capsule)
        #endif
    }

    @ViewBuilder func closeButton(isProminent: Bool = false) -> some View {
        let button = Button {
            close()
        } label: {
            #if !targetEnvironment(macCatalyst)
            ButtonLabel("Shared.Cancel", icon: "xmark")
            #else
            Text("Shared.Cancel")
            #endif
        }
        #if targetEnvironment(macCatalyst)
            .controlSize(.large)
        #endif
        Group {
            if isProminent {
                button
                    .buttonStyle(.borderedProminent)
            } else {
                button
                    .buttonStyle(.bordered)
            }
        }
        #if !targetEnvironment(macCatalyst)
        .clipShape(.capsule)
        #endif
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
                    if saveRecentAlbums {
                        if let albumName = selectedCollection.localizedTitle {
                            var existingRecentAlbums: [String] = (try? JSONDecoder().decode(
                                [String].self,
                                from: recentAlbumsData
                            )) ?? []
                            if existingRecentAlbums.contains(where: { $0 == albumName}) {
                                existingRecentAlbums.removeAll(where: { $0 == albumName})
                            }
                            existingRecentAlbums.append(albumName)
                            if existingRecentAlbums.count > 10 {
                                existingRecentAlbums = Array(existingRecentAlbums.suffix(10))
                            }
                            recentAlbumsData = (try? JSONEncoder().encode(existingRecentAlbums)) ?? Data()
                        }
                    }
                    if showSaveAnimation {
                        withAnimation(.smooth.speed(2.0)) {
                            isPhotoSaveSuccessful = true
                        } completion: {
                            closeWithHaptics()
                        }
                    } else {
                        closeWithHaptics(shouldWait: false)
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

    func closeWithHaptics(shouldWait: Bool = true) {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        if shouldWait {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                close()
            }
        } else {
            close()
        }
    }
}
