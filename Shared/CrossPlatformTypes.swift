//
//  CrossPlatformTypes.swift
//  Bromides
//
//  Created by シン・ジャスティン on 2025/08/24.
//

import SwiftUI

#if os(macOS)

import Cocoa

typealias XPImage = NSImage
typealias XPColor = NSColor
typealias XPViewController = NSViewController
typealias XPHostingController = NSHostingController

extension Image {
    init(xpImage: NSImage) {
        self.init(nsImage: xpImage)
    }
}

#else

import UIKit

typealias XPImage = UIImage
typealias XPColor = UIColor
typealias XPViewController = UIViewController
typealias XPHostingController = UIHostingController

extension Image {
    init(xpImage: UIImage) {
        self.init(uiImage: xpImage)
    }
}

#endif

extension XPImage {
    func data() -> Data? {
        #if os(macOS)
        if let tiffData = self.tiffRepresentation {
            return tiffData
        }
        #else
        if let pngData = self.pngData() {
            return pngData
        } else if let jpegData = self.jpegData(compressionQuality: 1.0) {
            return jpegData
        } else if let heicData = self.heicData() {
            return heicData
        }
        #endif
        return nil
    }
}
