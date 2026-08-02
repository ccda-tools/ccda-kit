import Foundation

/// Coded clinical value with optional display and code-system metadata.
public struct CCDACodedValue: Hashable, Sendable {
    /// Code value from the source XML.
    public let code: String?
    /// Code-system OID or identifier.
    public let codeSystem: String?
    /// Human-readable code-system name when present.
    public let codeSystemName: String?
    /// Human-readable display value for the code.
    public let displayName: String?

    /// Creates a coded clinical value.
    public init(
        code: String? = nil,
        codeSystem: String? = nil,
        codeSystemName: String? = nil,
        displayName: String? = nil
    ) {
        self.code = code
        self.codeSystem = codeSystem
        self.codeSystemName = codeSystemName
        self.displayName = displayName
    }
}
