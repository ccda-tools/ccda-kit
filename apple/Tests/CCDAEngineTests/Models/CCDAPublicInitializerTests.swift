import XCTest
import CCDAEngine

final class CCDAPublicInitializerTests: XCTestCase {
    func testPublicModelsCanBeConstructedByPackageUsers() throws {
        let documentId = CCDAIdentifier(root: "1.2.3", extensionValue: "doc-1")
        let templateId = CCDATemplateId(root: "2.16.840.1.113883.10.20.22.1.1")
        let timestamp = try XCTUnwrap(CCDATimestamp(rawValue: "20260719093000-0500"))
        let code = CCDACodedValue(code: "11450-4", displayName: "Problem List")
        let value = CCDAValue(type: "CD", code: "38341003", displayName: "Hypertension")
        let entry = CCDAEntry(
            id: "entry-1",
            type: .observation,
            templateIds: [templateId],
            identifiers: [CCDAIdentifier(root: "entry-1")],
            code: code,
            status: .completed,
            effectiveTime: timestamp,
            value: value,
            textReference: "#problem-1"
        )
        let media = CCDAMedia(
            id: "media-1",
            mediaType: .textPlain,
            representation: .base64,
            payload: .inlineBase64("SGVsbG8=")
        )
        let section = CCDASection(
            id: "section-problems",
            templateIds: [templateId],
            code: code,
            title: "Problems",
            narrativeText: "Hypertension",
            entries: [entry],
            media: [media]
        )
        let patient = CCDAPatient(
            ids: [CCDAIdentifier(root: "patient-1")],
            name: CCDAHumanName(prefix: "Ms.", given: ["Jane"], family: "Public"),
            gender: CCDACodedValue(code: "F", displayName: "Female"),
            birthTime: CCDATimestamp(rawValue: "19800515"),
            addresses: [
                CCDAAddress(
                    use: .primaryHome,
                    streetLines: ["123 Main St"],
                    city: "Boston",
                    state: "MA",
                    postalCode: "02118",
                    country: "US"
                )
            ],
            telecoms: ["tel:+1-555-0100"]
        )
        let header = CCDAHeader(
            realmCode: "US",
            typeId: CCDAIdentifier(root: "2.16.840.1.113883.1.3", extensionValue: "POCD_HD000040"),
            templateIds: [templateId],
            documentId: documentId,
            code: CCDACodedValue(code: "34133-9", displayName: "Summarization of Episode Note"),
            title: "Continuity of Care Document",
            effectiveTime: timestamp,
            confidentialityCode: CCDACodedValue(code: "N", displayName: "Normal"),
            languageCode: "en-US"
        )
        let document = CCDADocument(header: header, patient: patient, sections: [section])

        XCTAssertEqual(document.id, "1.2.3 / doc-1")
        XCTAssertEqual(document.patient?.name?.given, ["Jane"])
        XCTAssertEqual(document.sections.first?.kind, .problems)
        XCTAssertEqual(document.sections.first?.entries.first?.value?.displayName, "Hypertension")
    }

    func testAddressUseMapsKnownUnknownAndUnsupportedCodes() {
        XCTAssertEqual(CCDAAddressUse(code: "HP"), .primaryHome)
        XCTAssertEqual(CCDAAddressUse(code: "wp"), .workPlace)
        XCTAssertEqual(CCDAAddressUse(code: nil), .unknown)
        XCTAssertEqual(CCDAAddressUse(code: "VACATION"), .unsupported("VACATION"))
        XCTAssertEqual(CCDAAddressUse.primaryHome.code, "HP")
    }

    func testEntryTypeMapsKnownAndUnsupportedElementNames() {
        XCTAssertEqual(CCDAEntryType(elementName: "act"), .act)
        XCTAssertEqual(CCDAEntryType(elementName: "observation"), .observation)
        XCTAssertEqual(CCDAEntryType(elementName: "substanceAdministration"), .substanceAdministration)
        XCTAssertEqual(CCDAEntryType(elementName: "customEntry"), .unsupported("customEntry"))
        XCTAssertEqual(CCDAEntryType.observation.rawValue, "observation")
    }

    func testEntryStatusMapsKnownAndUnsupportedCodes() {
        XCTAssertEqual(CCDAEntryStatus(code: "active"), .active)
        XCTAssertEqual(CCDAEntryStatus(code: "completed"), .completed)
        XCTAssertEqual(CCDAEntryStatus(code: "custom-status"), .unsupported("custom-status"))
        XCTAssertEqual(CCDAEntryStatus.completed.rawValue, "completed")
    }
}
