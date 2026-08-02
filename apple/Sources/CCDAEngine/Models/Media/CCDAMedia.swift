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
