import Foundation

public struct CCDASection: Identifiable {
    public var id: String { code?.code ?? title ?? UUID().uuidString }
    public let templateIds: [CCDATemplateId]
    public let code: CCDACodedValue?
    public let title: String?
    public let narrativeText: String
    public let entries: [CCDAEntry]
    public let media: [CCDAMedia]
}
