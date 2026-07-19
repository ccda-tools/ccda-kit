import Foundation

public struct CCDAEntry: Identifiable {
    public let id = UUID()
    public let type: String
    public let templateIds: [CCDATemplateId]
    public let identifiers: [CCDAIdentifier]
    public let code: CCDACodedValue?
    public let status: String?
    public let effectiveTime: String?
    public let value: CCDAValue?
    public let textReference: String?
    public let children: [CCDAEntry]
}
