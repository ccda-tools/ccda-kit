import Foundation

/// C-CDA identifier represented by root and optional extension.
public struct CCDAIdentifier: Hashable, Sendable {
    /// Identifier root, often an OID.
    public let root: String?
    /// Identifier extension value.
    public let extensionValue: String?

    /// Creates an identifier value.
    public init(root: String? = nil, extensionValue: String? = nil) {
        self.root = root
        self.extensionValue = extensionValue
    }

    /// Identifier text combining root and extension.
    public var stringValue: String {
        [root, extensionValue].compactMap { $0 }.joined(separator: " / ")
    }
}
