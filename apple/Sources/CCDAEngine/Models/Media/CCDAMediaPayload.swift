import Foundation

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
