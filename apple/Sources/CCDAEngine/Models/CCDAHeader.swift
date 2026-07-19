import Foundation

/// Document-level metadata from the C-CDA header.
public struct CCDAHeader: Sendable {
    /// Realm code, usually `US` for U.S. C-CDA documents.
    public let realmCode: String?
    /// CDA type identifier.
    public let typeId: CCDAIdentifier?
    /// Header template identifiers.
    public let templateIds: [CCDATemplateId]
    /// Primary document identifier.
    public let documentId: CCDAIdentifier
    /// Document type code.
    public let code: CCDACodedValue?
    /// Document title.
    public let title: String?
    /// Document effective time parsed from the XML timestamp.
    public let effectiveTime: CCDATimestamp?
    /// Confidentiality classification code.
    public let confidentialityCode: CCDACodedValue?
    /// Document language code.
    public let languageCode: String?

    /// Creates document-level C-CDA header metadata.
    public init(
        realmCode: String? = nil,
        typeId: CCDAIdentifier? = nil,
        templateIds: [CCDATemplateId] = [],
        documentId: CCDAIdentifier,
        code: CCDACodedValue? = nil,
        title: String? = nil,
        effectiveTime: CCDATimestamp? = nil,
        confidentialityCode: CCDACodedValue? = nil,
        languageCode: String? = nil
    ) {
        self.realmCode = realmCode
        self.typeId = typeId
        self.templateIds = templateIds
        self.documentId = documentId
        self.code = code
        self.title = title
        self.effectiveTime = effectiveTime
        self.confidentialityCode = confidentialityCode
        self.languageCode = languageCode
    }
}
