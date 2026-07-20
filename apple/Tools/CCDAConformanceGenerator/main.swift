import Foundation
import CCDAEngine

struct ConformanceDocument: Codable, Equatable {
    let fileName: String
    let documentId: String
    let title: String?
    let documentCode: CodedSummary?
    let patientName: String?
    let patientBirthTime: String?
    let sectionCount: Int
    let sections: [SectionSummary]
}

struct SectionSummary: Codable, Equatable {
    let title: String?
    let code: CodedSummary?
    let templateIds: [String]
    let entryCount: Int
    let mediaCount: Int
}

struct CodedSummary: Codable, Equatable {
    let code: String?
    let displayName: String?
    let codeSystem: String?
}

let fileManager = FileManager.default
let workingDirectory = URL(fileURLWithPath: fileManager.currentDirectoryPath)
let configuredTestDataRoot = ProcessInfo.processInfo.environment["CCDA_TEST_DATA_ROOT"]
    .map { URL(fileURLWithPath: $0, isDirectory: true) }
let testDataRoot = configuredTestDataRoot
    ?? [
        workingDirectory.appendingPathComponent("test-data"),
        workingDirectory.appendingPathComponent("TestData"),
        workingDirectory.deletingLastPathComponent().appendingPathComponent("test-data")
    ].first { fileManager.fileExists(atPath: $0.path) }
    ?? workingDirectory.appendingPathComponent("test-data")
let inputDirectory = testDataRoot
    .appendingPathComponent("ccda")
    .appendingPathComponent("samples")
let outputDirectory = testDataRoot
    .appendingPathComponent("ccda")
    .appendingPathComponent("expected-output")

try fileManager.createDirectory(
    at: outputDirectory,
    withIntermediateDirectories: true
)

let sampleURLs = try fileManager
    .contentsOfDirectory(at: inputDirectory, includingPropertiesForKeys: nil)
    .filter { $0.pathExtension == "xml" }
    .sorted { $0.lastPathComponent < $1.lastPathComponent }

let engine = CCDAEngine()
let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]

for sampleURL in sampleURLs {
    let document = try engine.parse(url: sampleURL)
    let conformance = ConformanceDocument(document: document, fileName: sampleURL.lastPathComponent)
    let outputURL = outputDirectory
        .appendingPathComponent(sampleURL.deletingPathExtension().lastPathComponent)
        .appendingPathExtension("json")

    try encoder.encode(conformance).write(to: outputURL)
    print("Wrote \(outputURL.path)")
}

private extension ConformanceDocument {
    init(document: CCDADocument, fileName: String) {
        self.fileName = fileName
        self.documentId = document.header.documentId.display
        self.title = document.header.title
        self.documentCode = document.header.code.map(CodedSummary.init)
        self.patientName = document.patient?.name.map(Self.patientName)
        self.patientBirthTime = document.patient?.birthTime
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

private extension SectionSummary {
    init(section: CCDASection) {
        self.title = section.title
        self.code = section.code.map(CodedSummary.init)
        self.templateIds = section.templateIds.map(\.root).sorted()
        self.entryCount = section.entries.count
        self.mediaCount = section.media.count
    }
}

private extension CodedSummary {
    init(codedValue: CCDACodedValue) {
        self.code = codedValue.code
        self.displayName = codedValue.displayName
        self.codeSystem = codedValue.codeSystem
    }
}
