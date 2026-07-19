import Foundation

public struct CCDAPatient {
    public let ids: [CCDAIdentifier]
    public let name: CCDAHumanName?
    public let gender: CCDACodedValue?
    public let birthTime: String?
    public let maritalStatus: CCDACodedValue?
    public let race: CCDACodedValue?
    public let ethnicity: CCDACodedValue?
    public let addresses: [CCDAAddress]
    public let telecoms: [String]
}
