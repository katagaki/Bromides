//
//  ShareViewController.swift
//  Bromides
//
//  Created by シン・ジャスティン on 2025/03/22.
//

import SwiftData
@preconcurrency import SwiftUI
@preconcurrency import UIKit
import UniformTypeIdentifiers

class ShareViewController: UIViewController {

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
                case let uiImage as UIImage: loadedFile = uiImage
                case let data as Data: loadedFile = data
                default: loadedFile = nil
                }
                guard let loadedFile else { fatalError() }

                // Attach SwiftUI view to UIKit view
                let shareView = UIHostingController(rootView: ShareView(items: [loadedFile]))
                addChild(shareView)
                view.addSubview(shareView.view)
                shareView.view.translatesAutoresizingMaskIntoConstraints = false
                shareView.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
                shareView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
                shareView.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
                shareView.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
                view.bringSubviewToFront(shareView.view)
                #if targetEnvironment(macCatalyst)
                view.layer.cornerRadius = 10.0
                view.clipsToBounds = true
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
        self.dismiss(animated: false)
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
