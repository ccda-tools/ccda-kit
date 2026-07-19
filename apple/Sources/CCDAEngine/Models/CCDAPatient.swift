import Foundation

/// Patient demographics parsed from recordTarget.
public struct CCDAPatient: Sendable {
    /// Patient role identifiers.
    public let ids: [CCDAIdentifier]
    /// Patient name.
    public let name: CCDAHumanName?
    /// Administrative gender code.
    public let gender: CCDACodedValue?
    /// Birth time parsed from the XML timestamp.
    public let birthTime: CCDATimestamp?
    /// Marital status code.
    public let maritalStatus: CCDACodedValue?
    /// Race code.
    public let race: CCDACodedValue?
    /// Ethnicity code.
    public let ethnicity: CCDACodedValue?
    /// Patient addresses.
    public let addresses: [CCDAAddress]
    /// Patient telecom values such as phone or email URIs.
    public let telecoms: [String]

    /// Creates patient demographics.
    public init(
        ids: [CCDAIdentifier] = [],
        name: CCDAHumanName? = nil,
        gender: CCDACodedValue? = nil,
        birthTime: CCDATimestamp? = nil,
        maritalStatus: CCDACodedValue? = nil,
        race: CCDACodedValue? = nil,
        ethnicity: CCDACodedValue? = nil,
        addresses: [CCDAAddress] = [],
        telecoms: [String] = []
    ) {
        self.ids = ids
        self.name = name
        self.gender = gender
        self.birthTime = birthTime
        self.maritalStatus = maritalStatus
        self.race = race
        self.ethnicity = ethnicity
        self.addresses = addresses
        self.telecoms = telecoms
    }
}
