
import Komponents
import SwiftUI

extension ShareView {
    @ViewBuilder func portraitView(previewImage: XPImage) -> some View {
        VStack(alignment: .leading, spacing: 0.0) {
            ImagePreview(previewImage)
                .frame(maxWidth: .infinity, minHeight: 160.0, maxHeight: 160.0)
                .matchedGeometryEffect(id: "@$_bromidesPrivateIdentifier_preview", in: namespace)
            if isPhotoSaveSuccessful {
                SaveSuccessfulView(selectedCollections)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                Divider()
                    .ignoresSafeArea(.all, edges: .horizontal)
                ZStack(alignment: .center) {
                    if isPhotoSaving {
                        savingProgressView()
                    } else if isPhotosAuthorizationComplete {
                        if isPhotosAuthorizationDenied {
                            noAccessView()
                        } else {
                            CollectionsStack($navigator, selection: $selectedCollections, saveAction: save)
                                .matchedGeometryEffect(
                                    id: "@$_bromidesPrivateIdentifier_albumBrowser",
                                    in: namespace
                                )
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
