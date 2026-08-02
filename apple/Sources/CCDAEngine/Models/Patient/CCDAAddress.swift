import Foundation

/// Postal address information from a C-CDA patient role or related party.
public struct CCDAAddress: Hashable, Sendable {
    /// C-CDA address use, such as home or work.
    public let use: CCDAAddressUse
    /// Street address lines in document order.
    public let streetLines: [String]
    /// City or locality.
    public let city: String?
    /// State, province, or region.
    public let state: String?
    /// Postal or ZIP code.
    public let postalCode: String?
    /// Country text or code.
    public let country: String?

    /// Creates a postal address value.
    public init(
        use: CCDAAddressUse = .unknown,
        streetLines: [String] = [],
        city: String? = nil,
        state: String? = nil,
        postalCode: String? = nil,
        country: String? = nil
    ) {
        self.use = use
        self.streetLines = streetLines
        self.city = city
        self.state = state
        self.postalCode = postalCode
        self.country = country
    }
}
