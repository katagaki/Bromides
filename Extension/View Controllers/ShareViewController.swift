
import SwiftData
@preconcurrency import SwiftUI
#if os(macOS)
import AppKit
#else
@preconcurrency import UIKit
#endif
import UniformTypeIdentifiers

class ShareViewController: XPViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let item = extensionContext?.inputItems.first as? NSExtensionItem {
            guard let attachment = item.attachments?.first else { fatalError() }
            let utType: UTType = utTypeOf(attachment)
            setUpCloseObserver()

            Task { @MainActor in
                // Load attachment as image
                let file: Any? = try? await attachment.loadItem(forTypeIdentifier: utType.identifier)
                let loadedFile: (any Sendable)?
                switch file {
                case let url as URL: loadedFile = url
                case let uiImage as XPImage: loadedFile = uiImage
                case let data as Data: loadedFile = data
                default: loadedFile = nil
                }
                guard let loadedFile else { fatalError() }

                // Attach SwiftUI view to UIKit view
                let shareViewController = XPHostingController(rootView: ShareView(items: [loadedFile]))
                #if os(macOS)
                self.view = shareViewController.view
                self.view.frame = .init(x: 0, y: 0, width: 500.0, height: 400.0)
                #else
                addChild(shareViewController)
                view.addSubview(shareViewController.view)
                shareViewController.view.translatesAutoresizingMaskIntoConstraints = false
                shareViewController.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
                shareViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
                shareViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
                shareViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
                view.bringSubviewToFront(shareViewController.view)
                #endif
            }
        }
    }

    func setUpCloseObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(close),
            name: NSNotification.Name("close"),
            object: nil
        )
    }

    @objc func close() {
        extensionContext?.completeRequest(returningItems: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("close"), object: nil)
        #if os(macOS)
        self.dismiss(self)
        #else
        self.dismiss(animated: false)
        #endif
    }

    func utTypeOf(_ attachment: NSItemProvider) -> UTType {
        var utType: UTType?
        if attachment.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
            utType = .image
        } else if attachment.hasItemConformingToTypeIdentifier(UTType.png.identifier) {
            utType = .png
        } else if attachment.hasItemConformingToTypeIdentifier(UTType.jpeg.identifier) {
            utType = .jpeg
        } else if attachment.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
            utType = .url
        } else if attachment.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
            utType = .fileURL
        }
        guard let utType else { fatalError() }
        return utType
    }
}
