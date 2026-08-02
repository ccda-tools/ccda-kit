import Foundation

/// Known media types with fallback for vendor-specific MIME values.
public enum CCDAMediaType: Hashable, Sendable {
    case imagePNG
    case imageJPEG
    case imageGIF
    case applicationPDF
    case textPlain
    case textHTML
    case unsupported(String)
    case unknown

    /// Creates a media type from a MIME string.
    public init(mimeType: String?) {
        guard let mimeType, !mimeType.isEmpty else {
            self = .unknown
            return
        }

        switch mimeType.lowercased() {
        case "image/png":
            self = .imagePNG
        case "image/jpeg", "image/jpg":
            self = .imageJPEG
        case "image/gif":
            self = .imageGIF
        case "application/pdf":
            self = .applicationPDF
        case "text/plain":
            self = .textPlain
        case "text/html":
            self = .textHTML
        default:
            self = .unsupported(mimeType)
        }
    }

    /// MIME string for this media type when known.
    public var mimeType: String? {
        switch self {
        case .imagePNG:
            return "image/png"
        case .imageJPEG:
            return "image/jpeg"
        case .imageGIF:
            return "image/gif"
        case .applicationPDF:
            return "application/pdf"
        case .textPlain:
            return "text/plain"
        case .textHTML:
            return "text/html"
        case .unsupported(let value):
            return value
        case .unknown:
            return nil
        }
    }

    /// Whether this type is an image MIME type.
    public var isImage: Bool {
        mimeType?.hasPrefix("image/") == true
    }
}
