import Foundation

/// Parsed C-CDA document containing header, patient, and section data.
public struct CCDADocument: Identifiable, Sendable {
    /// Stable document identity derived from the header document ID.
    public var id: String { header.documentId.stringValue }
    /// Document-level metadata.
    public let header: CCDAHeader
    /// Patient demographics when present.
    public let patient: CCDAPatient?
    /// Structured body sections parsed from the document.
    public let sections: [CCDASection]

    /// Creates a parsed C-CDA document model.
    public init(
        header: CCDAHeader,
        patient: CCDAPatient? = nil,
        sections: [CCDASection] = []
    ) {
        self.header = header
        self.patient = patient
        self.sections = sections
    }
}
