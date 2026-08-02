import Foundation

/// Structured clinical entry inside a C-CDA section.
public struct CCDAEntry: Identifiable, Sendable {
    /// Stable identity for list and tree rendering.
    public let id: String
    /// XML element type for the entry, such as observation or substanceAdministration.
    public let type: CCDAEntryType
    /// Template identifiers attached to this entry.
    public let templateIds: [CCDATemplateId]
    /// Entry identifiers.
    public let identifiers: [CCDAIdentifier]
    /// Primary coded concept for the entry.
    public let code: CCDACodedValue?
    /// Entry status code, when present.
    public let status: CCDAEntryStatus?
    /// Effective time value or low/high fallback parsed from the XML timestamp.
    public let effectiveTime: CCDATimestamp?
    /// Entry value parsed from the direct value element.
    public let value: CCDAValue?
    /// Narrative text reference, usually an anchor such as `#problem-1`.
    public let textReference: String?
    /// Nested entries from entryRelationship or component children.
    public let children: [CCDAEntry]

    /// Creates a structured clinical entry.
    public init(
        id: String,
        type: CCDAEntryType,
        templateIds: [CCDATemplateId] = [],
        identifiers: [CCDAIdentifier] = [],
        code: CCDACodedValue? = nil,
        status: CCDAEntryStatus? = nil,
        effectiveTime: CCDATimestamp? = nil,
        value: CCDAValue? = nil,
        textReference: String? = nil,
        children: [CCDAEntry] = []
    ) {
        self.id = id
        self.type = type
        self.templateIds = templateIds
        self.identifiers = identifiers
        self.code = code
        self.status = status
        self.effectiveTime = effectiveTime
        self.value = value
        self.textReference = textReference
        self.children = children
    }
}
