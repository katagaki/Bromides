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
    
    @State var selectedCollection: PHAssetCollection? = nil
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
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0.0) {
            if let imageData, let uiImage = UIImage(data: imageData) {
                ImagePreview(uiImage: uiImage)
                Divider()
                ZStack(alignment: .center) {
                    if isPhotosAuthorizationDenied {
                        ContentUnavailableView("Could not access your Photos library", systemImage: "xmark.circle.fill")
                            .symbolRenderingMode(.multicolor)
                    } else {
                        NavigationStack(path: $viewPath) {
                            AlbumView(selection: $selectedCollection)
                                .navigationDestination(for: Collection.self) { collection in
                                    AlbumView(collection, selection: $selectedCollection)
                                }
                        }
                    }
                }
                .layoutPriority(0)
                Divider()
                HStack {
                    Button {
                        // TODO
                    } label: {
                        ButtonLabel("Save", icon: "square.and.arrow.down")
                    }
                    .buttonStyle(.borderedProminent)
                    .clipShape(.capsule)
                    .disabled(selectedCollection == nil)
                    Button {
                        close()
                    } label: {
                        ButtonLabel("Cancel", icon: "xmark")
                    }
                    .buttonStyle(.bordered)
                    .clipShape(.capsule)
                }
                .padding()
            } else {
                Spacer()
                ContentUnavailableView("Could not load image", systemImage: "photo.badge.exclamationmark.fill")
                    .padding()
                Spacer()
                Divider()
                Button {
                    close()
                } label: {
                    ButtonLabel("Close", icon: "xmark")
                }
                .buttonStyle(.borderedProminent)
                .clipShape(.capsule)
                .padding()
            }
        }
        .task {
            PhotosLibrary.requestAuthorization { status in
                switch status {
                case .authorized:
                    isPhotosAuthorizationDenied = false
                default:
                    isPhotosAuthorizationDenied = true
                }
            }
        }
    }

    func close() {
        NotificationCenter.default.post(name: NSNotification.Name("close"), object: nil)
    }
}
