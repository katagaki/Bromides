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
    @AppStorage(wrappedValue: false, "AllowSaveWithoutAlbum", store: defaults) var allowSaveWithoutAlbum: Bool
    @AppStorage(wrappedValue: Data(), "RecentAlbums", store: defaults) var recentAlbumsData: Data

    @State var navigator: Navigator = Navigator()
    var imageData: Data?
    var previewImage: XPImage?

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
        } else if let image = item as? XPImage {
            self.imageData = image.data()
        } else if let data = item as? Data {
            self.imageData = data
        }
        guard let imageData = self.imageData else { return }
        #if os(macOS)
        guard let previewImage = XPImage(data: imageData) else { return }
        #else
        guard let previewImage = XPImage(data: imageData)?
            .preparingThumbnail(of: .init(width: 600.0, height: 600.0)) else { return }
        #endif
        self.previewImage = previewImage
    }

    var body: some View {
        if imageData != nil, let previewImage {
            Group {
                #if os(macOS)
                macView(previewImage: previewImage)
                #else
                if verticalSizeClass == .regular && horizontalSizeClass == .compact {
                    portraitView(previewImage: previewImage)
                } else {
                    landscapeView(previewImage: previewImage)
                }
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
            .onChange(of: navigator.debouncingSearchTerm) { _, _ in
                navigator.debounceSearch()
            }
            .onKeyPress(.escape) {
                close()
                return .handled
            }
            .alert("Error.SaveFailed", isPresented: $isPhotoSaveFailed) {
                Button(role: .close, action: {})
            }
        } else {
            VStack(alignment: .center) {
                Spacer()
                ContentUnavailableView("Error.NoImage", systemImage: "photo.badge.exclamationmark.fill")
                Button(role: .close, action: close)
                    .controlSize(.large)
                    .buttonStyle(.glass)
                Spacer()
            }
            .padding()
        }
    }

    @ViewBuilder
    func noAccessView() -> some View {
        VStack(alignment: .center) {
            ContentUnavailableView("Error.PhotosAccess", systemImage: "xmark.circle.fill")
                .symbolRenderingMode(.multicolor)
            Button(role: .close, action: close)
                .controlSize(.large)
                .buttonStyle(.glass)
        }
    }

    func save() {
        if !isPhotoSaving, let imageData {
            // Check if we have a selected collection or if saving without album is allowed
            if selectedCollection != nil || allowSaveWithoutAlbum {
                isPhotoSaving = true
                Task {
                    let isPhotoSaved: Bool
                    if let selectedCollection {
                        isPhotoSaved = await PhotosLibrary.saveImage(
                            data: imageData,
                            to: selectedCollection
                        )
                    } else {
                        isPhotoSaved = await PhotosLibrary.saveImage(data: imageData)
                    }
                    
                    if isPhotoSaved {
                        if saveRecentAlbums, let selectedCollection {
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
                        #if os(iOS)
                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                        #endif
                        isPhotoSaving = false
                        isPhotoSaveFailed = true
                    }
                }
            } else {
                isPhotoSaveFailed = true
            }
        } else {
            isPhotoSaveFailed = true
        }
    }

    func closeWithHaptics(shouldWait: Bool = true) {
        #if os(iOS)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
        if shouldWait {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                close()
            }
        } else {
            close()
        }
    }
}
