#if canImport(UIKit)
import SnapshotTesting
import SwiftUI
import UIKit
import XCTest
@testable import CCDAEngine
@testable import CCDAUI

@MainActor
final class CCDAUISnapshotTests: XCTestCase {
    private let snapshotSize = CGSize(width: 720, height: 760)
    private var snapshotWindows: [UIWindow] = []

    func testDefaultDocumentViewLightAppearance() {
        assertSnapshot(
            of: hostingController(
                CCDADocumentView(document: Self.makeDocument()),
                colorScheme: .light,
                size: snapshotSize
            ),
            as: .image(
                precision: 0.99,
                perceptualPrecision: 0.98,
                size: snapshotSize
            )
        )
    }

    func testDefaultDocumentViewDarkAppearance() {
        assertSnapshot(
            of: hostingController(
                CCDADocumentView(document: Self.makeDocument()),
                colorScheme: .dark,
                size: snapshotSize
            ),
            as: .image(
                precision: 0.99,
                perceptualPrecision: 0.98,
                size: snapshotSize
            )
        )
    }

    func testNestedEntryRow() {
        let view = CCDAEntryRow(entry: Self.makeEntry())
            .padding()
            .frame(width: 520, height: 220, alignment: .topLeading)

        assertSnapshot(
            of: hostingController(
                view,
                colorScheme: .light,
                size: CGSize(width: 520, height: 220)
            ),
            as: .image(
                precision: 0.99,
                perceptualPrecision: 0.98,
                size: CGSize(width: 520, height: 220)
            )
        )
    }

    func testMediaRows() {
        let view = NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                CCDAMediaView(media: Self.makeMedia(id: "pdf", type: .applicationPDF))
                CCDAMediaView(media: Self.makeMedia(id: "text", type: .textPlain))
                CCDAMediaView(media: Self.makeMedia(id: "html", type: .textHTML))
                CCDAMediaView(
                    media: Self.makeMedia(
                        id: "unsupported",
                        type: .unsupported("application/dicom")
                    )
                )
                CCDAMediaView(media: Self.makeMedia(id: "unknown", type: .unknown))
            }
            .padding()
            .frame(width: 520, height: 280, alignment: .topLeading)
        }

        assertSnapshot(
            of: hostingController(
                view,
                colorScheme: .light,
                size: CGSize(width: 520, height: 280)
            ),
            as: .image(
                precision: 0.99,
                perceptualPrecision: 0.98,
                size: CGSize(width: 520, height: 280)
            )
        )
    }

    private func hostingController<Content: View>(
        _ content: Content,
        colorScheme: ColorScheme,
        size: CGSize
    ) -> UIHostingController<some View> {
        let controller = UIHostingController(
            rootView: content
                .environment(\.colorScheme, colorScheme)
                .environment(\.locale, Locale(identifier: "en_US_POSIX"))
                .frame(width: size.width, height: size.height)
                .background(Color(uiColor: .systemBackground))
        )
        controller.overrideUserInterfaceStyle = colorScheme == .dark ? .dark : .light
        controller.view.frame = CGRect(origin: .zero, size: size)
        let window = UIWindow(frame: CGRect(origin: .zero, size: size))
        window.overrideUserInterfaceStyle = controller.overrideUserInterfaceStyle
        window.rootViewController = controller
        window.makeKeyAndVisible()
        controller.view.setNeedsLayout()
        controller.view.layoutIfNeeded()
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))
        controller.view.layoutIfNeeded()
        snapshotWindows.append(window)
        return controller
    }

    private static func makeDocument() -> CCDADocument {
        CCDADocument(
            header: CCDAHeader(
                realmCode: "US",
                documentId: CCDAIdentifier(root: "1.2.3.4", extensionValue: "public-1"),
                code: CCDACodedValue(
                    code: "34133-9",
                    codeSystem: "2.16.840.1.113883.6.1",
                    codeSystemName: "LOINC",
                    displayName: "Summary of episode note"
                ),
                title: "Continuity of Care Document",
                languageCode: "en-US"
            ),
            patient: CCDAPatient(
                ids: [CCDAIdentifier(root: "1.2.3.4.5", extensionValue: "patient-1")],
                name: CCDAHumanName(prefix: "Ms.", given: ["Jane", "Q."], family: "Public"),
                gender: CCDACodedValue(
                    code: "F",
                    codeSystem: nil,
                    codeSystemName: nil,
                    displayName: "Female"
                ),
                addresses: [
                    CCDAAddress(
                        use: "HP",
                        streetLines: ["100 Test Avenue"],
                        city: "Example",
                        state: "MA",
                        postalCode: "01234",
                        country: "US"
                    )
                ]
            ),
            sections: [
                CCDASection(
                    id: "problems",
                    code: CCDACodedValue(
                        code: "11450-4",
                        codeSystem: "2.16.840.1.113883.6.1",
                        codeSystemName: "LOINC",
                        displayName: "Problem List"
                    ),
                    kind: .problems,
                    title: "Problems",
                    narrativeText: "Active conditions reported in this synthetic document.",
                    entries: [makeEntry()]
                ),
                CCDASection(
                    id: "attachments",
                    title: "Attachments",
                    media: [
                        makeMedia(id: "pdf", type: .applicationPDF),
                        makeMedia(id: "unsupported", type: .unsupported("application/dicom"))
                    ]
                )
            ]
        )
    }

    private static func makeEntry() -> CCDAEntry {
        CCDAEntry(
            type: "observation",
            code: CCDACodedValue(
                code: "38341003",
                codeSystem: "2.16.840.1.113883.6.96",
                codeSystemName: "SNOMED CT",
                displayName: "Hypertension"
            ),
            status: "active",
            value: CCDAValue(type: "CD", displayName: "Essential hypertension"),
            children: [
                CCDAEntry(
                    type: "observation",
                    code: CCDACodedValue(
                        code: "75367002",
                        codeSystem: "2.16.840.1.113883.6.96",
                        codeSystemName: "SNOMED CT",
                        displayName: "Blood pressure"
                    ),
                    status: "completed",
                    value: CCDAValue(type: "PQ", value: "120", unit: "mm[Hg]")
                )
            ]
        )
    }

    private static func makeMedia(id: String, type: CCDAMediaType) -> CCDAMedia {
        CCDAMedia(
            id: id,
            mediaType: type,
            representation: .unknown,
            payload: .unavailable
        )
    }
}
#endif
