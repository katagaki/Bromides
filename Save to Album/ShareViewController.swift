//
//  ShareViewController.swift
//  Save to Album
//
//  Created by シン・ジャスティン on 2025/03/22.
//

import SwiftData
import SwiftUI
import UIKit
import UniformTypeIdentifiers

class ShareViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let item = extensionContext?.inputItems.first as? NSExtensionItem {
            let attachments = item.attachments ?? []
            Task {
                var loadedFiles: [Any] = []
                for attachment: NSItemProvider in attachments {
                    var loadedFile: Any?
                    if attachment.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                        loadedFile = await loadItem(attachment, type: UTType.image)
                    } else if attachment.hasItemConformingToTypeIdentifier(UTType.png.identifier) {
                        loadedFile = await loadItem(attachment, type: UTType.png)
                    } else if attachment.hasItemConformingToTypeIdentifier(UTType.jpeg.identifier) {
                        loadedFile = await loadItem(attachment, type: UTType.jpeg)
                    } else if attachment.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                        loadedFile = await loadItem(attachment, type: UTType.url)
                    } else if attachment.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                        loadedFile = await loadItem(attachment, type: UTType.fileURL)
                    }
                    if let loadedFile {
                        loadedFiles.append(loadedFile)
                    }
                }
                DispatchQueue.main.async { [self] in
                    let shareView = UIHostingController(rootView: ShareView(items: loadedFiles))
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
    }

    func close() {
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }

    func loadItem(_ attachment: NSItemProvider, type: UTType) async -> Any? {
        return await withCheckedContinuation { continuation in
            attachment.loadItem(forTypeIdentifier: type.identifier, options: nil) { file, _ in
                continuation.resume(returning: (file))
            }
        }
    }
}
