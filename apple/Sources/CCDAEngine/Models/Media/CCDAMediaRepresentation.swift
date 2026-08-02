import Foundation

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
