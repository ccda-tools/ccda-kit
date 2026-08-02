import Foundation

/// Human name split into common C-CDA name parts.
public struct CCDAHumanName: Hashable, Sendable {
    /// Prefix such as Mr., Ms., or Dr.
    public let prefix: String?
    /// Given names in document order.
    public let given: [String]
    /// Family or last name.
    public let family: String?

    /// Creates a human name value.
    public init(
        prefix: String? = nil,
        given: [String] = [],
        family: String? = nil
    ) {
        self.prefix = prefix
        self.given = given
        self.family = family
    }
}
