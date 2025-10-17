//
//  SaveSuccessfulView.swift
//  Bromides
//
//  Created by シン・ジャスティン on 2025/04/05.
//

import Photos
import SwiftUI

struct SaveSuccessfulView: View {
    var navigator: Navigator
    
    @State private var albumNames: String = ""

    init(_ navigator: Navigator) {
        self.navigator = navigator
    }

    var body: some View {
        VStack(alignment: .center, spacing: 16.0) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 48.0, height: 48.0)
                .symbolRenderingMode(.multicolor)
            
            if navigator.selectedAlbumIdentifiers.isEmpty {
                Text("Message.Save.CameraRoll")
                    .bold()
            } else if !albumNames.isEmpty {
                Text("Message.Save.\(albumNames)")
                    .bold()
                    .multilineTextAlignment(.center)
            }
        }
        .task {
            if !navigator.selectedAlbumIdentifiers.isEmpty {
                let albums = PhotosLibrary.albumsFromIdentifiers(Array(navigator.selectedAlbumIdentifiers))
                albumNames = albums.compactMap { $0.localizedTitle }.joined(separator: ", ")
            }
        }
    }
}
