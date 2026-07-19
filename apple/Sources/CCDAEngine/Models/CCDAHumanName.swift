import Foundation

public struct CCDAHumanName: Hashable {
    public let prefix: String?
    public let given: [String]
    public let family: String?

    public var display: String {
        ([prefix] + given + [family]).compactMap { $0 }.joined(separator: " ")
    }
}
