import Foundation

/// Errors raised while loading media payload data.
public enum CCDAMediaPayloadError: Error, Equatable, Sendable {
    /// Inline base64 payload could not be decoded.
    case invalidBase64
    /// No payload is available.
    case unavailable
}
