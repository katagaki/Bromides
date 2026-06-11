
import SwiftUI
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

struct ImagePreview: View {
    var image: XPImage

    init(_ image: XPImage) {
        self.image = image
    }

    var body: some View {
        VStack(alignment: .center) {
            Image(xpImage: image)
                .resizable()
                .clipShape(.rect(cornerRadius: 6.0))
                .aspectRatio(contentMode: .fit)
                .shadow(radius: 3.0, y: 2.0)
                .padding()
        }
    }
}
