import SwiftUI
import CCDAEngine

/// Default media renderer for C-CDA attachments.
public struct CCDAMediaView: View {
    /// Media to render.
    public let media: CCDAMedia

    /// Creates a media renderer.
    public init(media: CCDAMedia) {
        self.media = media
    }

    /// SwiftUI view body.
    public var body: some View {
        switch media.mediaType {
        case .imagePNG, .imageJPEG, .imageGIF:
            CCDAMediaImageView(media: media)
        case .applicationPDF, .textPlain, .textHTML:
            NavigationLink {
                CCDAMediaWebView(media: media)
                    .navigationTitle(title)
            } label: {
                CCDAMediaLabel(title: title, systemImageName: systemImageName)
            }
        case .unsupported(let mimeType):
            CCDAMediaLabel(title: "Unsupported attachment: \(mimeType)", systemImageName: "paperclip")
        case .unknown:
            CCDAMediaLabel(title: "Attachment", systemImageName: "paperclip")
        }
    }

    private var title: String {
        switch media.mediaType {
        case .applicationPDF:
            return "PDF"
        case .textPlain:
            return "Text"
        case .textHTML:
            return "HTML"
        case .imagePNG, .imageJPEG, .imageGIF:
            return "Image"
        case .unsupported(let mimeType):
            return mimeType
        case .unknown:
            return "Attachment"
        }
    }

    private var systemImageName: String {
        switch media.mediaType {
        case .applicationPDF:
            return "doc.richtext"
        case .textPlain:
            return "doc.text"
        case .textHTML:
            return "globe"
        default:
            return "paperclip"
        }
    }
}

private struct CCDAMediaLabel: View {
    let title: String
    let systemImageName: String

    var body: some View {
        Label(title, systemImage: systemImageName)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(CCDATheme.attachment)
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(CCDATheme.attachment.opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: CCDATheme.cornerRadius, style: .continuous))
    }
}
