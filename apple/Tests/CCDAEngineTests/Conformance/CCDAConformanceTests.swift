import XCTest
@testable import CCDAEngine

final class CCDAConformanceTests: XCTestCase {
    func testMatchesConformanceExpectedOutput() throws {
        let sampleURLs = try CCDASampleFixtures.ccdaSampleURLs()

        XCTAssertFalse(sampleURLs.isEmpty, "Expected sample C-CDA files in test-data/ccda.")

        let engine = CCDAEngine()
        let decoder = JSONDecoder()

        for url in sampleURLs {
            let document = try engine.parse(url: url)
            let actual = ConformanceDocument(document: document, fileName: url.lastPathComponent)
            let expectedURL = CCDASampleFixtures.conformanceExpectedOutputURL(for: url)

            XCTAssertTrue(
                FileManager.default.fileExists(atPath: expectedURL.path),
                "Missing conformance output for \(url.lastPathComponent). Run `swift run CCDAConformanceGenerator`."
            )

            let expected = try decoder.decode(
                ConformanceDocument.self,
                from: Data(contentsOf: expectedURL)
            )

            XCTAssertEqual(actual, expected, "Conformance mismatch for \(url.lastPathComponent).")
        }
    }
}

private struct ConformanceDocument: Codable, Equatable {
    let fileName: String
    let documentId: String
    let title: String?
    let documentCode: CodedSummary?
    let patientName: String?
    let patientBirthTime: String?
    let sectionCount: Int
    let sections: [SectionSummary]

    init(document: CCDADocument, fileName: String) {
        self.fileName = fileName
        self.documentId = document.header.documentId.stringValue
        self.title = document.header.title
        self.documentCode = document.header.code.map(CodedSummary.init)
        self.patientName = document.patient?.name.map(Self.patientName)
        self.patientBirthTime = document.patient?.birthTime?.rawValue
        self.sectionCount = document.sections.count
        self.sections = document.sections.map(SectionSummary.init)
    }
}

private extension ConformanceDocument {
    static func patientName(_ name: CCDAHumanName) -> String {
        ([name.prefix] + name.given + [name.family])
            .compactMap { $0 }
            .joined(separator: " ")
    }
}

private struct SectionSummary: Codable, Equatable {
    let title: String?
    let code: CodedSummary?
    let templateIds: [String]
    let entryCount: Int
    let mediaCount: Int

    init(section: CCDASection) {
        self.title = section.title
        self.code = section.code.map(CodedSummary.init)
        self.templateIds = section.templateIds.map(\.root).sorted()
        self.entryCount = section.entries.count
        self.mediaCount = section.media.count
    }
}

private struct CodedSummary: Codable, Equatable {
    let code: String?
    let displayName: String?
    let codeSystem: String?

    init(codedValue: CCDACodedValue) {
        self.code = codedValue.code
        self.displayName = codedValue.displayName
        self.codeSystem = codedValue.codeSystem
    }
}
