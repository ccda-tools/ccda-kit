import SwiftUI
import CCDAEngine

public struct CCDADocumentView: View {
    public let document: CCDADocument

    public init(document: CCDADocument) {
        self.document = document
    }

    public var body: some View {
        CCDAComposableDocumentView(
            document: document,
            header: { header in
                Section("Document") {
                    if let title = header.title {
                        LabeledContent("Title", value: title)
                    }
                    if let date = header.effectiveTime {
                        LabeledContent("Effective Time", value: date)
                    }
                    LabeledContent("Document ID", value: header.documentId.display)
                }
            },
            patient: { patient in
                Section("Patient") {
                    if let name = patient.name?.display {
                        LabeledContent("Name", value: name)
                    }
                    if let birthTime = patient.birthTime {
                        LabeledContent("DOB", value: birthTime)
                    }
                    if let gender = patient.gender?.displayName ?? patient.gender?.code {
                        LabeledContent("Gender", value: gender)
                    }
                    ForEach(patient.addresses, id: \.self) { address in
                        LabeledContent("Address", value: address.display)
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
                CCDAMediaImageView(media: media)
            }
        )
    }
}
