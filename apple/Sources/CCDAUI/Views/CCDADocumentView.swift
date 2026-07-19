import SwiftUI
import CCDAEngine

/// Default SwiftUI renderer for a parsed C-CDA document.
public struct CCDADocumentView: View {
    /// Parsed document to render.
    public let document: CCDADocument

    /// Creates the default document renderer.
    public init(document: CCDADocument) {
        self.document = document
    }

    /// SwiftUI view body.
    public var body: some View {
        CCDAComposableDocumentView(
            document: document,
            header: { header in
                Section("Document") {
                    if let title = header.title {
                        LabeledContent("Title", value: title)
                    }
                    if let date = header.effectiveTime {
                        LabeledContent("Effective Time", value: date.formattedDateTime)
                    }
                    LabeledContent("Document ID", value: header.documentId.stringValue)
                }
            },
            patient: { patient in
                Section("Patient") {
                    if let name = patient.name?.formattedName, !name.isEmpty {
                        LabeledContent("Name", value: name)
                    }
                    if let birthTime = patient.birthTime {
                        LabeledContent("DOB", value: birthTime.formattedDateTime)
                    }
                    if let gender = patient.gender?.displayName ?? patient.gender?.code {
                        LabeledContent("Gender", value: gender)
                    }
                    ForEach(patient.addresses, id: \.self) { address in
                        LabeledContent("Address", value: address.formattedPostalAddress)
                    }
                }
            },
            section: { section, entryView, mediaView in
                Section(section.title ?? section.code?.displayName ?? "Section") {
                    if !section.narrativeText.isEmpty {
                        Text(section.narrativeText)
                            .font(.body)
                    }
                    ForEach(section.entries) { entry in
                        entryView(entry)
                    }
                    ForEach(section.media) { media in
                        mediaView(media)
                    }
                }
            },
            entry: { entry in
                CCDAEntryRow(entry: entry)
            },
            media: { media in
                CCDAMediaView(media: media)
            }
        )
    }
}
