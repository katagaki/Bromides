
import Komponents
import SwiftUI

extension ShareView {
    @ViewBuilder func macView(previewImage: XPImage) -> some View {
        VStack(alignment: .leading, spacing: 0.0) {
            if isPhotoSaveSuccessful {
                SaveSuccessfulView(selectedCollections)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ZStack(alignment: .center) {
                    if isPhotoSaving {
                        savingProgressView()
                    } else if isPhotosAuthorizationComplete {
                        if isPhotosAuthorizationDenied {
                            noAccessView()
                        } else {
                            CollectionsStack($navigator, selection: $selectedCollections, saveAction: save)
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
