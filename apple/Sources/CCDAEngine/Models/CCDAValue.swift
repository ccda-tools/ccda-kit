import Foundation

public struct CCDAValue: Hashable {
    public let type: String?
    public let code: String?
    public let displayName: String?
    public let value: String?
    public let unit: String?

    public var display: String {
        if let displayName {
            return displayName
        }

        return [value, unit].compactMap { $0 }.joined(separator: " ")
    }
}
