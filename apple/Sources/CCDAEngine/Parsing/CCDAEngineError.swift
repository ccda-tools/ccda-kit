import Foundation

/// Errors produced by the C-CDA engine.
public enum CCDAEngineError: Error, CustomStringConvertible, LocalizedError, Sendable {
    /// XML could not be parsed into a document.
    case invalidXML(CCDAXMLParsingFailure)
    /// Embedded media could not be written to the configured cache.
    case mediaCacheWriteFailed(URL, String)

    /// Human-readable error detail.
    public var description: String {
        switch self {
        case .invalidXML(let failure):
            return failure.description
        case .mediaCacheWriteFailed(let url, let message):
            return "Unable to cache C-CDA media at \(url.path): \(message)"
        }
    }

    /// Localized error text.
    public var errorDescription: String? {
        description
    }
}

/// Detailed XML parser failure context.
public struct CCDAXMLParsingFailure: Equatable, Sendable, CustomStringConvertible {
    /// Parser failure message.
    public let message: String
    /// One-based line number when available.
    public let lineNumber: Int?
    /// One-based column number when available.
    public let columnNumber: Int?
    /// File path or caller-provided source description.
    public let sourceDescription: String?
    /// Underlying parser error description when available.
    public let underlyingErrorDescription: String?

    /// Creates XML parser failure context.
    public init(
        message: String,
        lineNumber: Int? = nil,
        columnNumber: Int? = nil,
        sourceDescription: String? = nil,
        underlyingErrorDescription: String? = nil
    ) {
        self.message = message
        self.lineNumber = lineNumber
        self.columnNumber = columnNumber
        self.sourceDescription = sourceDescription
        self.underlyingErrorDescription = underlyingErrorDescription
    }

    /// Human-readable failure summary.
    public var description: String {
        var parts = ["Invalid C-CDA XML: \(message)"]

        if let sourceDescription {
            parts.append("source: \(sourceDescription)")
        }

        if let lineNumber, let columnNumber {
            parts.append("line: \(lineNumber), column: \(columnNumber)")
        } else if let lineNumber {
            parts.append("line: \(lineNumber)")
        } else if let columnNumber {
            parts.append("column: \(columnNumber)")
        }

        if let underlyingErrorDescription {
            parts.append("underlying error: \(underlyingErrorDescription)")
        }

        return parts.joined(separator: "; ")
    }
}
