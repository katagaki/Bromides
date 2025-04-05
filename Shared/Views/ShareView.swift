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
        @Bindable var navigator = navigator
        VStack(alignment: .leading, spacing: 0.0) {
            if imageData != nil, let previewImage {
                ImagePreview(previewImage)
                if isPhotoSaveSuccessful {
                    SaveSuccessfulView(selectedCollection)
                    .frame(maxWidth: .infinity)
                    .padding()
                } else {
                    Divider()
                    ZStack(alignment: .center) {
                        if isPhotosAuthorizationComplete {
                            if isPhotosAuthorizationDenied {
                                ContentUnavailableView("Error.PhotosAccess", systemImage: "xmark.circle.fill")
                                    .symbolRenderingMode(.multicolor)
                            } else {
                                NavigationStack(path: $navigator.viewPath) {
                                    CollectionView(selection: $selectedCollection)
                                        .environment(navigator)
                                        .navigationDestination(for: Collection.self) { collection in
                                            CollectionView(collection, selection: $selectedCollection)
                                                .environment(navigator)
                                        }
                                }
                                .safeAreaInset(edge: .bottom, spacing: 0.0) {
                                    BarAccessory(placement: .bottom, isBackgroundSolid: false) {
                                        VStack(spacing: 16.0) {
                                            SearchField()
                                                .environment(navigator)
                                            HStack {
                                                Group {
                                                    Button {
                                                        save()
                                                    } label: {
                                                        ButtonLabel("Shared.Save", icon: "square.and.arrow.down")
                                                    }
                                                    .buttonStyle(.borderedProminent)
                                                    .disabled(selectedCollection == nil || isPhotoSaving)
                                                    Button {
                                                        close()
                                                    } label: {
                                                        ButtonLabel("Shared.Cancel", icon: "xmark")
                                                    }
                                                    .buttonStyle(.bordered)
                                                    .disabled(isPhotoSaving)
                                                }
                                                .clipShape(.capsule)
                                            }
                                        }
                                        .padding()
                                    }
                                }
                            }
                        } else {
                            VStack(alignment: .center) {
                                ProgressView()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                    .layoutPriority(0)
                }
            } else {
                Spacer()
                ContentUnavailableView("Error.NoImage", systemImage: "photo.badge.exclamationmark.fill")
                    .padding()
                Spacer()
                Divider()
                Button {
                    close()
                } label: {
                    ButtonLabel("Shared.Close", icon: "xmark")
                }
                .buttonStyle(.borderedProminent)
                .clipShape(.capsule)
                .padding()
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
        .onChange(of: navigator.searchTerm) { _, newValue in
            if !newValue.trimmingCharacters(in: .whitespaces).isEmpty {
                navigator.startSearching()
            } else if newValue.trimmingCharacters(in: .whitespaces).isEmpty {
                navigator.stopSearching()
            }
        }
        .onChange(of: navigator.viewPath) { oldValue, newValue in
            if oldValue.contains(.search) && !newValue.contains(.search) {
                navigator.stopSearching()
            }
        }
        .alert("Error.SaveFailed", isPresented: $isPhotoSaveFailed) {
            Button("Shared.Dismiss", action: {})
        }
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
