import Foundation

/// Embedded or referenced media parsed from C-CDA observationMedia entries.
public struct CCDAMedia: Identifiable, Sendable {
    /// Media identifier from XML or a generated fallback.
    public let id: String
    /// Typed media/MIME value.
    public let mediaType: CCDAMediaType
    /// C-CDA representation value.
    public let representation: CCDAMediaRepresentation
    /// Payload storage for the media.
    public let payload: CCDAMediaPayload

    /// Loads decoded media data from the payload.
    public func loadData() throws -> Data {
        switch payload {
        case .cachedFile(let url, _):
            return try Data(contentsOf: url)
        case .inlineBase64(let value):
            guard let data = Data(base64Encoded: value.filter { !$0.isWhitespace }) else {
                throw CCDAMediaPayloadError.invalidBase64
            }
            return data
        case .unavailable:
            throw CCDAMediaPayloadError.unavailable
        }
    }

    /// Whether the media type represents an image.
    public var isImage: Bool {
        mediaType.isImage
    }

    /// Whether this media payload is stored outside the model.
    public var isCached: Bool {
        if case .cachedFile = payload {
            return true
        }
        return false
    }

    /// Creates a media value.
    public init(
        id: String,
        mediaType: CCDAMediaType,
        representation: CCDAMediaRepresentation,
        payload: CCDAMediaPayload
    ) {
        self.id = id
        self.mediaType = mediaType
        self.representation = representation
        self.payload = payload
    }
}

/// Errors raised while loading media payload data.
public enum CCDAMediaPayloadError: Error, Equatable, Sendable {
    /// Inline base64 payload could not be decoded.
    case invalidBase64
    /// No payload is available.
    case unavailable
}

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

/// C-CDA media representation metadata.
public enum CCDAMediaRepresentation: Hashable, Sendable {
    case base64
    case text
    case unsupported(String)
    case unknown

    /// Creates a representation from the XML value.
    public init(rawValue: String?) {
        guard let rawValue, !rawValue.isEmpty else {
            self = .unknown
            return
        }

        switch rawValue.uppercased() {
        case "B64":
            self = .base64
        case "TXT":
            self = .text
        default:
            self = .unsupported(rawValue)
        }
    }

    /// XML representation value when known.
    public var rawValue: String? {
        switch self {
        case .base64:
            return "B64"
        case .text:
            return "TXT"
        case .unsupported(let value):
            return value
        case .unknown:
            return nil
        }
    }
}

/// Media payload storage.
public enum CCDAMediaPayload: Hashable, Sendable {
    /// Payload decoded and written to disk.
    case cachedFile(URL, byteCount: Int)
    /// Payload kept as base64 text, usually when caching is disabled or decoding fails.
    case inlineBase64(String)
    /// Payload was not available or could not be represented.
    case unavailable

    /// Cached file URL when payload is cache-backed.
    public var fileURL: URL? {
        if case .cachedFile(let url, _) = self {
            return url
        }
        return nil
    }

    /// Decoded byte count when known.
    public var byteCount: Int? {
        if case .cachedFile(_, let byteCount) = self {
            return byteCount
        }
        return nil
    }
}
