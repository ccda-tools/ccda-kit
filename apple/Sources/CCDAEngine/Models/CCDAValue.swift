import Foundation

/// Value parsed from an entry value element.
public struct CCDAValue: Hashable, Sendable {
    /// XML or xsi type for the value.
    public let type: String?
    /// Coded value.
    public let code: String?
    /// Human-readable coded display.
    public let displayName: String?
    /// Scalar value.
    public let value: String?
    /// Unit for scalar values.
    public let unit: String?

    /// Creates an entry value.
    public init(
        type: String? = nil,
        code: String? = nil,
        displayName: String? = nil,
        value: String? = nil,
        unit: String? = nil
    ) {
        self.type = type
        self.code = code
        self.displayName = displayName
        self.value = value
        self.unit = unit
    }
}
