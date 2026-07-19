import XCTest
@testable import CCDAEngine

final class CCDAEngineErrorTests: XCTestCase {
    func testInvalidXMLIncludesParserLocationAndMessage() {
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <ClinicalDocument xmlns="urn:hl7-org:v3">
            <title>Broken C-CDA</title>
            <component>
        </ClinicalDocument>
        """

        XCTAssertThrowsError(try CCDAEngine().parse(data: Data(xml.utf8))) { error in
            guard case CCDAEngineError.invalidXML(let failure) = error else {
                return XCTFail("Expected CCDAEngineError.invalidXML, got \(error).")
            }

            XCTAssertFalse(failure.message.isEmpty)
            XCTAssertNotNil(failure.lineNumber)
            XCTAssertNotNil(failure.columnNumber)
            XCTAssertNil(failure.sourceDescription)
            XCTAssertTrue(failure.description.contains("Invalid C-CDA XML"))
            XCTAssertTrue(failure.description.contains("line:"))
            XCTAssertTrue(failure.description.contains("column:"))
        }
    }

    func testInvalidXMLFromURLIncludesSourceDescription() throws {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("xml")

        try Data("<ClinicalDocument><title>Broken</ClinicalDocument>".utf8).write(to: fileURL)
        defer {
            try? FileManager.default.removeItem(at: fileURL)
        }

        XCTAssertThrowsError(try CCDAEngine().parse(url: fileURL)) { error in
            guard case CCDAEngineError.invalidXML(let failure) = error else {
                return XCTFail("Expected CCDAEngineError.invalidXML, got \(error).")
            }

            XCTAssertEqual(failure.sourceDescription, fileURL.path)
            XCTAssertTrue(failure.description.contains(fileURL.path))
        }
    }
}
