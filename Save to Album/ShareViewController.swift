//
//  ShareViewController.swift
//  Save to Album
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
            Task { @MainActor in
                guard let loadedFile = await loadItem(attachment, type: utType) else { fatalError() }
                let shareView = UIHostingController(rootView: ShareView(items: [loadedFile]))
                addChild(shareView)
                view.addSubview(shareView.view)
                shareView.view.translatesAutoresizingMaskIntoConstraints = false
                shareView.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
                shareView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
                shareView.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
                shareView.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
                view.bringSubviewToFront(shareView.view)
                NotificationCenter.default.addObserver(forName: NSNotification.Name("close"),
                                                       object: nil, queue: nil) { _ in
                    DispatchQueue.main.async { [self] in
                        close()
                    }
                }
            }
        }
    }

    func close() {
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }

    func loadItem(_ attachment: NSItemProvider, type: UTType) async -> (any Sendable)? {
        let file: Any? = try? await attachment.loadItem(forTypeIdentifier: type.identifier)
        let sendableResult: (any Sendable)?
        switch file {
        case let url as URL:
            sendableResult = url
        case let uiImage as UIImage:
            sendableResult = uiImage
        case let data as Data:
            sendableResult = data
        default:
            sendableResult = nil
        }
        return sendableResult
    }
}
