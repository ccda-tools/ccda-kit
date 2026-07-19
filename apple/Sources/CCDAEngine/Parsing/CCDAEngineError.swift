import Foundation

public enum CCDAEngineError: Error, CustomStringConvertible, LocalizedError {
    case invalidXML(CCDAXMLParsingFailure)

    public var description: String {
        switch self {
        case .invalidXML(let failure):
            return failure.description
        }
    }

    public var errorDescription: String? {
        description
    }
}

public struct CCDAXMLParsingFailure: Equatable, Sendable, CustomStringConvertible {
    public let message: String
    public let lineNumber: Int?
    public let columnNumber: Int?
    public let sourceDescription: String?
    public let underlyingErrorDescription: String?

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
