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
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 14) {
                CCDADocumentHeaderPanel(header: document.header)

                if let patient = document.patient {
                    CCDAPatientPanel(patient: patient)
                }

                ForEach(document.sections) { section in
                    CCDASectionPanel(section: section)
                }
            }
            .padding(16)
        }
        .background(CCDATheme.pageBackground)
    }
}

private struct CCDADocumentHeaderPanel: View {
    let header: CCDAHeader

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(header.title ?? header.code?.displayName ?? "C-CDA Document", systemImage: "doc.text.magnifyingglass")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)

//            HStack(alignment: .top, spacing: 12) {
                CCDASummaryPill(title: "Document ID", value: header.documentId.stringValue, systemImage: "number")
                if let date = header.effectiveTime {
                    CCDASummaryPill(title: "Effective", value: date.formattedDateTime, systemImage: "calendar")
                }
                if let language = header.languageCode {
                    CCDASummaryPill(title: "Language", value: language, systemImage: "globe")
                }
//            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CCDATheme.primary)
        .clipShape(RoundedRectangle(cornerRadius: CCDATheme.cornerRadius, style: .continuous))
    }
}

private struct CCDAPatientPanel: View {
    let patient: CCDAPatient

    var body: some View {
        CCDAInfoPanel(title: "Patient", systemImage: "person.text.rectangle", accent: CCDATheme.secondary) {
            if let name = patient.name?.formattedName, !name.isEmpty {
                CCDALabeledValue(title: "Name", value: name)
            }
            if let birthTime = patient.birthTime {
                CCDALabeledValue(title: "DOB", value: birthTime.formattedDateTime)
            }
            if let gender = patient.gender?.displayName ?? patient.gender?.code {
                CCDALabeledValue(title: "Gender", value: gender)
            }
            ForEach(patient.addresses, id: \.self) { address in
                CCDALabeledValue(title: "Address", value: address.formattedPostalAddress)
            }
        }
    }
}

private struct CCDASectionPanel: View {
    let section: CCDASection

    var body: some View {
        CCDAInfoPanel(
            title: section.title ?? section.code?.displayName ?? "Section",
            systemImage: "folder",
            accent: CCDATheme.primary
        ) {
            if !section.narrativeText.isEmpty {
                Text(section.narrativeText)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .padding(.bottom, 4)
            }

            ForEach(section.entries) { entry in
                CCDAEntryRow(entry: entry)
            }

            ForEach(section.media) { media in
                CCDAMediaView(media: media)
            }
        }
    }
}

private struct CCDAInfoPanel<Content: View>: View {
    let title: String
    let systemImage: String
    let accent: Color
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .foregroundStyle(accent)

            VStack(alignment: .leading, spacing: 10) {
                content
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CCDATheme.panelBackground)
        .clipShape(RoundedRectangle(cornerRadius: CCDATheme.cornerRadius, style: .continuous))
    }
}

private struct CCDALabeledValue: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title.uppercased())
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
    }
}

private struct CCDASummaryPill: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.76))
                Text(value)
                    .font(.caption)
                    .lineLimit(2)
                    .foregroundStyle(.white)
            }
        } icon: {
            Image(systemName: systemImage)
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.14))
        .clipShape(RoundedRectangle(cornerRadius: CCDATheme.cornerRadius, style: .continuous))
    }
}
