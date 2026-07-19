import Foundation

public struct CCDAIdentifier: Hashable {
    public let root: String?
    public let extensionValue: String?

    public var display: String {
        [root, extensionValue].compactMap { $0 }.joined(separator: " / ")
    }
}
