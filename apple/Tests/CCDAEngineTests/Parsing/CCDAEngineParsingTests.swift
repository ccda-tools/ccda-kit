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

    func testDataURLAndStreamParsingProduceEquivalentDocuments() throws {
        let data = Data(Self.entryPointXML.utf8)
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("ccda-entry-point-\(UUID().uuidString)")
            .appendingPathExtension("xml")
        try data.write(to: fileURL)
        defer { try? FileManager.default.removeItem(at: fileURL) }

        let engine = CCDAEngine()
        let dataDocument = try engine.parse(data: data)
        let urlDocument = try engine.parse(url: fileURL)
        let stream = InputStream(data: data)
        let streamDocument = try engine.parse(stream: stream)

        XCTAssertEqual(summary(dataDocument), summary(urlDocument))
        XCTAssertEqual(summary(dataDocument), summary(streamDocument))
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

    private func summary(_ document: CCDADocument) -> [String] {
        [
            document.header.documentId.stringValue,
            document.header.title ?? "",
            document.patient?.name?.given.joined(separator: " ") ?? "",
            document.patient?.name?.family ?? "",
            String(document.sections.count),
            document.sections.first?.id ?? "",
            document.sections.first?.title ?? "",
            document.sections.first?.entries.first?.id ?? "",
            document.sections.first?.entries.first?.status?.rawValue ?? "",
            document.sections.first?.media.first?.id ?? ""
        ]
    }

    private static let entryPointXML = """
    <?xml version="1.0" encoding="UTF-8"?>
    <ClinicalDocument xmlns="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
        <id root="1.2.3" extension="doc-1"/>
        <title>Entry Point CCD</title>
        <recordTarget>
            <patientRole>
                <id root="patient-1"/>
                <patient>
                    <name><given>Jane</given><family>Public</family></name>
                </patient>
            </patientRole>
        </recordTarget>
        <component>
            <structuredBody>
                <component>
                    <section>
                        <code code="11450-4" displayName="Problem List"/>
                        <title>Problems</title>
                        <text>Hypertension</text>
                        <entry>
                            <observation>
                                <id root="problem-1"/>
                                <statusCode code="active"/>
                                <value xsi:type="CD" code="38341003" displayName="Hypertension"/>
                            </observation>
                        </entry>
                        <entry>
                            <observationMedia ID="media-1">
                                <value mediaType="text/plain" representation="B64">aGVsbG8=</value>
                            </observationMedia>
                        </entry>
                    </section>
                </component>
            </structuredBody>
        </component>
    </ClinicalDocument>
    """
}
