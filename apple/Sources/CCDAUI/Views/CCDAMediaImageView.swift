import Foundation
import SwiftUI
import CCDAEngine

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

public struct CCDAMediaImageView: View {
    public let media: CCDAMedia

    public init(media: CCDAMedia) {
        self.media = media
    }

    public var body: some View {
        if media.isImage, let data = media.data, let image = platformImage(data: data) {
            image
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 180)
        }
    }

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
}
