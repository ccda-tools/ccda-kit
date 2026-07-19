import SwiftUI
import CCDAEngine

/// Generic SwiftUI document view with host-provided rendering closures.
public struct CCDAComposableDocumentView<HeaderContent: View,
                                       PatientContent: View,
                                       SectionContent: View>: View {
    /// Parsed C-CDA document to render.
    public let document: CCDADocument

    /// Host renderer for document header content.
    private let headerContent: (CCDAHeader) -> HeaderContent
    /// Host renderer for patient content.
    private let patientContent: (CCDAPatient) -> PatientContent
    /// Host renderer for each section and its entry/media renderers.
    private let sectionContent: (CCDASection, @escaping (CCDAEntry) -> AnyView, @escaping (CCDAMedia) -> AnyView) -> SectionContent
    /// Type-erased host renderer for entries.
    private let entryContent: (CCDAEntry) -> AnyView
    /// Type-erased host renderer for media.
    private let mediaContent: (CCDAMedia) -> AnyView

    /// Creates a composable document view with custom renderers.
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

    /// SwiftUI view body.
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
