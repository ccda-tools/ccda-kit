import Foundation

/// Structured C-CDA section with narrative, entries, and media.
public struct CCDASection: Identifiable, Sendable {
    /// Stable section identity.
    public let id: String
    /// Section template identifiers.
    public let templateIds: [CCDATemplateId]
    /// Section code.
    public let code: CCDACodedValue?
    /// Recognized C-CDA section category based on the section code.
    public let kind: CCDASectionKind
    /// Section title.
    public let title: String?
    /// Cleaned narrative text from the section text element.
    public let narrativeText: String
    /// Structured clinical entries in the section.
    public let entries: [CCDAEntry]
    /// Media entries attached to the section.
    public let media: [CCDAMedia]

    /// Creates a structured C-CDA section.
    public init(
        id: String? = nil,
        templateIds: [CCDATemplateId] = [],
        code: CCDACodedValue? = nil,
        kind: CCDASectionKind? = nil,
        title: String? = nil,
        narrativeText: String = "",
        entries: [CCDAEntry] = [],
        media: [CCDAMedia] = []
    ) {
        self.id = id ?? code?.code ?? title ?? UUID().uuidString
        self.templateIds = templateIds
        self.code = code
        self.kind = kind ?? CCDASectionKind(code: code?.code)
        self.title = title
        self.narrativeText = narrativeText
        self.entries = entries
        self.media = media
    }
}
