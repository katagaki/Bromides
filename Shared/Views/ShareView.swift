//
//  ShareView.swift
//  Bromides
//
//  Created by シン・ジャスティン on 2025/03/22.
//

import Photos
import SwiftData
import SwiftUI

struct ShareView: View {

    @State var viewPath: [Collection] = []
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
        VStack(alignment: .leading, spacing: 0.0) {
            if let imageData, let previewImage {
                ImagePreview(uiImage: previewImage)
                if isPhotoSaveSuccessful {
                    VStack(alignment: .center, spacing: 16.0) {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .frame(width: 48.0, height: 48.0)
                            .symbolRenderingMode(.multicolor)
                        Text("""
Message.Save.\(selectedCollection?.localizedTitle ?? NSLocalizedString("Shared.Album", comment: ""))
""")
                            .bold()
                    }
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
                                NavigationStack(path: $viewPath) {
                                    AlbumView(selection: $selectedCollection)
                                        .navigationDestination(for: Collection.self) { collection in
                                            AlbumView(collection, selection: $selectedCollection)
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
                    Divider()
                    HStack {
                        Button {
                            if let selectedCollection {
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
                            }
                        } label: {
                            ButtonLabel("Shared.Save", icon: "square.and.arrow.down")
                        }
                        .buttonStyle(.borderedProminent)
                        .clipShape(.capsule)
                        .disabled(selectedCollection == nil || isPhotoSaving)
                        Button {
                            close()
                        } label: {
                            ButtonLabel("Shared.Cancel", icon: "xmark")
                        }
                        .buttonStyle(.bordered)
                        .clipShape(.capsule)
                        .disabled(isPhotoSaving)
                    }
                    .padding()
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
        .alert("Error.SaveFailed", isPresented: $isPhotoSaveFailed) {
            Button("Shared.Dismiss", action: {})
        }
    }

    func close() {
        NotificationCenter.default.post(name: NSNotification.Name("close"), object: nil)
    }
}
