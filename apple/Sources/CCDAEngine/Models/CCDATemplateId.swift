import Foundation

/// C-CDA template identifier.
public struct CCDATemplateId: Hashable, Sendable {
    /// Template root OID.
    public let root: String
    /// Template version or extension value.
    public let extensionValue: String?

    /// Creates a template identifier.
    public init(root: String, extensionValue: String? = nil) {
        self.root = root
        self.extensionValue = extensionValue
    }
}
