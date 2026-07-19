import XCTest
@testable import CCDAEngine

final class CCDAEngineParsingTests: XCTestCase {
    func testParsesMinimalCCDADocument() throws {
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <ClinicalDocument xmlns="urn:hl7-org:v3">
            <realmCode code="US"/>
            <templateId root="2.16.840.1.113883.10.20.22.1.1"/>
            <id root="1.2.3" extension="doc-1"/>
            <title>Sample CCD</title>
            <recordTarget>
                <patientRole>
                    <id root="1.2.3.4" extension="patient-1"/>
                    <patient>
                        <name><given>John</given><family>Doe</family></name>
                        <birthTime value="19800515"/>
                    </patient>
                </patientRole>
            </recordTarget>
            <component>
                <structuredBody>
                    <component>
                        <section>
                            <templateId root="2.16.840.1.113883.10.20.22.2.1.1"/>
                            <code code="10160-0" displayName="History of Medication Use"/>
                            <title>Medications</title>
                            <text><table><tbody><tr><td>Lisinopril</td></tr></tbody></table></text>
                        </section>
                    </component>
                </structuredBody>
            </component>
        </ClinicalDocument>
        """

        let document = try CCDAEngine().parse(data: Data(xml.utf8))

        XCTAssertEqual(document.header.title, "Sample CCD")
        XCTAssertEqual(document.patient?.name?.given, ["John"])
        XCTAssertEqual(document.patient?.name?.family, "Doe")
        XCTAssertEqual(document.sections.count, 1)
        XCTAssertEqual(document.sections.first?.title, "Medications")
        XCTAssertEqual(document.sections.first?.narrativeText, "Lisinopril")
    }

    func testParsesSharedCCDASampleFiles() throws {
        let sampleURLs = try CCDASampleFixtures.ccdaSampleURLs()

        XCTAssertFalse(sampleURLs.isEmpty, "Expected sample C-CDA files in test-data/ccda.")

        let engine = CCDAEngine()

        for url in sampleURLs {
            let document = try engine.parse(url: url)

            XCTAssertFalse(
                document.header.documentId.stringValue.isEmpty,
                "Expected document ID in \(url.lastPathComponent)."
            )
            XCTAssertTrue(
                document.header.title != nil || document.header.code != nil || !document.sections.isEmpty,
                "Expected header or section data in \(url.lastPathComponent)."
            )
        }
    }
}
