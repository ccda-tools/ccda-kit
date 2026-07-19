import SwiftUI
import CCDAEngine

public struct CCDAComposableDocumentView<HeaderContent: View,
                                       PatientContent: View,
                                       SectionContent: View>: View {
    public let document: CCDADocument

    private let headerContent: (CCDAHeader) -> HeaderContent
    private let patientContent: (CCDAPatient) -> PatientContent
    private let sectionContent: (CCDASection, @escaping (CCDAEntry) -> AnyView, @escaping (CCDAMedia) -> AnyView) -> SectionContent
    private let entryContent: (CCDAEntry) -> AnyView
    private let mediaContent: (CCDAMedia) -> AnyView

    public init<EntryContent: View, MediaContent: View>(
        document: CCDADocument,
        @ViewBuilder header: @escaping (CCDAHeader) -> HeaderContent,
        @ViewBuilder patient: @escaping (CCDAPatient) -> PatientContent,
        @ViewBuilder section: @escaping (CCDASection, @escaping (CCDAEntry) -> AnyView, @escaping (CCDAMedia) -> AnyView) -> SectionContent,
        @ViewBuilder entry: @escaping (CCDAEntry) -> EntryContent,
        @ViewBuilder media: @escaping (CCDAMedia) -> MediaContent
    ) {
        self.document = document
        self.headerContent = header
        self.patientContent = patient
        self.sectionContent = section
        self.entryContent = { AnyView(entry($0)) }
        self.mediaContent = { AnyView(media($0)) }
    }

    public var body: some View {
        List {
            headerContent(document.header)

            if let patient = document.patient {
                patientContent(patient)
            }

            ForEach(document.sections) { section in
                sectionContent(
                    section,
                    entryContent,
                    mediaContent
                )
            }
        }
    }
}
