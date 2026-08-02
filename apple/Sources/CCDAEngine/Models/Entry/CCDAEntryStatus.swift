import Foundation

/// Status code attached to a structured C-CDA entry.
public enum CCDAEntryStatus: Hashable, Sendable {
    /// Entry is currently active.
    case active
    /// Entry has been completed.
    case completed
    /// Entry was aborted before completion.
    case aborted
    /// Entry was cancelled.
    case cancelled
    /// Entry is temporarily suspended.
    case suspended
    /// Entry is temporarily held.
    case held
    /// Entry is newly created or pending.
    case new
    /// Entry status is normal.
    case normal
    /// Entry has been made obsolete.
    case obsolete
    /// Entry has been nullified.
    case nullified
    /// Unsupported status code preserved from source XML.
    case unsupported(String)

    /// Creates an entry status from a C-CDA `statusCode/@code` value.
    public init(code: String) {
        switch code {
        case "active":
            self = .active
        case "completed":
            self = .completed
        case "aborted":
            self = .aborted
        case "cancelled":
            self = .cancelled
        case "suspended":
            self = .suspended
        case "held":
            self = .held
        case "new":
            self = .new
        case "normal":
            self = .normal
        case "obsolete":
            self = .obsolete
        case "nullified":
            self = .nullified
        default:
            self = .unsupported(code)
        }
    }

    /// Original C-CDA status code.
    public var rawValue: String {
        switch self {
        case .active:
            return "active"
        case .completed:
            return "completed"
        case .aborted:
            return "aborted"
        case .cancelled:
            return "cancelled"
        case .suspended:
            return "suspended"
        case .held:
            return "held"
        case .new:
            return "new"
        case .normal:
            return "normal"
        case .obsolete:
            return "obsolete"
        case .nullified:
            return "nullified"
        case .unsupported(let rawValue):
            return rawValue
        }
    }
}
