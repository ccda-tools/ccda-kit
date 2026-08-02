import Foundation
import XCTest
@testable import CCDAEngine

final class CCDAModelTests: XCTestCase {
    func testIdentifierStringValueCombinesRootAndExtension() {
        XCTAssertEqual(
            CCDAIdentifier(root: "1.2.3", extensionValue: "abc").stringValue,
            "1.2.3 / abc"
        )
        XCTAssertEqual(CCDAIdentifier(root: "1.2.3", extensionValue: nil).stringValue, "1.2.3")
        XCTAssertEqual(CCDAIdentifier(root: nil, extensionValue: "abc").stringValue, "abc")
        XCTAssertEqual(CCDAIdentifier(root: nil, extensionValue: nil).stringValue, "")
    }

    func testValueStoresMappedFields() {
        let value = CCDAValue(
            type: "PQ",
            code: "8480-6",
            displayName: "Systolic blood pressure",
            value: "120",
            unit: "mm[Hg]"
        )

        XCTAssertEqual(value.type, "PQ")
        XCTAssertEqual(value.code, "8480-6")
        XCTAssertEqual(value.displayName, "Systolic blood pressure")
        XCTAssertEqual(value.value, "120")
        XCTAssertEqual(value.unit, "mm[Hg]")
    }

    func testDocumentIdUsesHeaderDocumentIdDisplay() {
        let document = CCDADocument(
            header: CCDAHeader(
                realmCode: nil,
                typeId: nil,
                templateIds: [],
                documentId: CCDAIdentifier(root: "2.16.840", extensionValue: "doc-1"),
                code: nil,
                title: nil,
                effectiveTime: nil,
                confidentialityCode: nil,
                languageCode: nil
            ),
            patient: nil,
            sections: []
        )

        XCTAssertEqual(document.id, "2.16.840 / doc-1")
    }

    func testSectionUsesProvidedId() {
        let codedSection = CCDASection(
            id: "section-medications",
            templateIds: [],
            code: CCDACodedValue(
                code: "10160-0",
                codeSystem: nil,
                codeSystemName: nil,
                displayName: "Medications"
            ),
            kind: .medications,
            title: "Medication List",
            narrativeText: "",
            entries: [],
            media: []
        )

        let titledSection = CCDASection(
            id: "section-allergies",
            templateIds: [],
            code: nil,
            kind: .unknown(code: nil),
            title: "Allergies",
            narrativeText: "",
            entries: [],
            media: []
        )

        XCTAssertEqual(codedSection.id, "section-medications")
        XCTAssertEqual(titledSection.id, "section-allergies")
    }

    func testSectionKindMapsCommonCCDASectionCodes() {
        XCTAssertEqual(CCDASectionKind(code: "48765-2"), .allergies)
        XCTAssertEqual(CCDASectionKind(code: "10160-0"), .medications)
        XCTAssertEqual(CCDASectionKind(code: "11450-4"), .problems)
        XCTAssertEqual(CCDASectionKind(code: "8716-3"), .vitalSigns)
        XCTAssertEqual(CCDASectionKind(code: "local-code"), .unknown(code: "local-code"))
        XCTAssertEqual(CCDASectionKind(code: nil), .unknown(code: nil))
    }
}
