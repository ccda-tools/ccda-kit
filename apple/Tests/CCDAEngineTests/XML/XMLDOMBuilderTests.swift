import XCTest
@testable import CCDAEngine

final class XMLDOMBuilderTests: XCTestCase {
    func testBuildsDOMWithNamespaceProcessingAndAttributes() throws {
        let root = try parseRoot(
            """
            <ClinicalDocument xmlns="urn:hl7-org:v3">
                <recordTarget>
                    <patientRole>
                        <id root="1.2.3" extension="patient-1"/>
                    </patientRole>
                </recordTarget>
            </ClinicalDocument>
            """
        )

        XCTAssertEqual(root.name, "ClinicalDocument")

        let patientRole = try XCTUnwrap(root.first(.patientRole))
        let id = try XCTUnwrap(patientRole.first(.id))

        XCTAssertEqual(id.attribute(.root), "1.2.3")
        XCTAssertEqual(id.attribute(.extension), "patient-1")
        XCTAssertTrue(id.isNamed(.id))
    }

    func testDirectOnlyReturnsImmediateChildren() throws {
        let root = try parseRoot(
            """
            <ClinicalDocument xmlns="urn:hl7-org:v3">
                <templateId root="top"/>
                <component>
                    <section>
                        <templateId root="nested"/>
                    </section>
                </component>
            </ClinicalDocument>
            """
        )

        XCTAssertEqual(root.direct(.templateId).count, 1)
        XCTAssertEqual(root.direct(.templateId).first?.attribute(.root), "top")
        XCTAssertEqual(root.first(.templateId)?.attribute(.root), "top")
        XCTAssertEqual(root.first(.section)?.first(.templateId)?.attribute(.root), "nested")
    }

    func testCleanTextNormalizesWhitespaceAndIncludesDescendants() throws {
        let root = try parseRoot(
            """
            <ClinicalDocument xmlns="urn:hl7-org:v3">
                <text>
                    First
                    <table>
                        <tbody>
                            <tr><td>Second</td><td>Third</td></tr>
                        </tbody>
                    </table>
                </text>
            </ClinicalDocument>
            """
        )

        XCTAssertEqual(root.first(.text)?.cleanText, "First Second Third")
    }

    private func parseRoot(_ xml: String) throws -> CCDAXMLNode {
        let builder = XMLDOMBuilder()
        let parser = XMLParser(data: Data(xml.utf8))
        parser.delegate = builder
        parser.shouldProcessNamespaces = true

        XCTAssertTrue(parser.parse())
        return try XCTUnwrap(builder.root)
    }
}
