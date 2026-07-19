import SwiftUI
import XCTest
@testable import CCDAEngine
@testable import CCDAUI

final class CCDAViewConstructionTests: XCTestCase {
    func testDefaultDocumentViewKeepsDocumentAvailable() {
        let document = Self.makeDocument()
        let view = CCDADocumentView(document: document)

        XCTAssertEqual(view.document.header.title, "Continuity of Care Document")
        XCTAssertEqual(view.document.sections.first?.kind, .problems)
    }

    func testComposableDocumentViewAcceptsHostRenderers() {
        let document = Self.makeDocument()
        let view = CCDAComposableDocumentView(
            document: document,
            header: { header in
                Text(header.title ?? "")
            },
            patient: { patient in
                Text(patient.birthTime?.formattedDateTime ?? "")
            },
            section: { section, _, _ in
                Text(section.title ?? "")
            },
            entry: { entry in
                Text(entry.type)
            },
            media: { media in
                Text(media.id)
            }
        )

        XCTAssertEqual(view.document.sections.count, 1)
    }

    private static func makeDocument() -> CCDADocument {
        CCDADocument(
            header: CCDAHeader(
                realmCode: "US",
                typeId: nil,
                templateIds: [],
                documentId: CCDAIdentifier(root: "1.2.3", extensionValue: "doc-1"),
                code: nil,
                title: "Continuity of Care Document",
                effectiveTime: nil,
                confidentialityCode: nil,
                languageCode: nil
            ),
            patient: CCDAPatient(
                ids: [],
                name: CCDAHumanName(prefix: nil, given: ["Jane"], family: "Public"),
                gender: nil,
                birthTime: CCDATimestamp(rawValue: "19800101"),
                maritalStatus: nil,
                race: nil,
                ethnicity: nil,
                addresses: [],
                telecoms: []
            ),
            sections: [
                CCDASection(
                    templateIds: [],
                    code: CCDACodedValue(
                        code: "11450-4",
                        codeSystem: nil,
                        codeSystemName: nil,
                        displayName: "Problem List"
                    ),
                    kind: .problems,
                    title: "Problems",
                    narrativeText: "Hypertension",
                    entries: [],
                    media: []
                )
            ]
        )
    }
}
