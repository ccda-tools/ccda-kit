import Foundation

public struct CCDAAddress: Hashable {
    public let use: String?
    public let streetLines: [String]
    public let city: String?
    public let state: String?
    public let postalCode: String?
    public let country: String?

    public var display: String {
        (streetLines + [city, state, postalCode, country].compactMap { $0 })
            .joined(separator: ", ")
    }
}
