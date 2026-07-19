import Foundation
import SwiftUI
import CCDAEngine

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/// Default image renderer for embedded C-CDA media.
public struct CCDAMediaImageView: View {
    /// Media payload to render when it is an image.
    public let media: CCDAMedia
    @State private var image: Image?

    /// Creates an image view for C-CDA media.
    public init(media: CCDAMedia) {
        self.media = media
    }

    /// SwiftUI view body.
    public var body: some View {
        Group {
            if let image {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 180)
            }
        }
        .task(id: media.id) {
            loadImage()
        }
    }

    /// Converts raw image data into the platform SwiftUI image type.
    private func platformImage(data: Data) -> Image? {
        #if os(iOS)
        guard let uiImage = UIImage(data: data) else { return nil }
        return Image(uiImage: uiImage)
        #elseif os(macOS)
        guard let nsImage = NSImage(data: data) else { return nil }
        return Image(nsImage: nsImage)
        #else
        return nil
        #endif
    }

    private func loadImage() {
        guard media.isImage else {
            image = nil
            return
        }

        do {
            image = try platformImage(data: media.loadData())
        } catch {
            image = nil
        }
    }
}
