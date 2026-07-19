import Foundation

public struct CCDAHeader {
    public let realmCode: String?
    public let typeId: CCDAIdentifier?
    public let templateIds: [CCDATemplateId]
    public let documentId: CCDAIdentifier
    public let code: CCDACodedValue?
    public let title: String?
    public let effectiveTime: String?
    public let confidentialityCode: CCDACodedValue?
    public let languageCode: String?
}
