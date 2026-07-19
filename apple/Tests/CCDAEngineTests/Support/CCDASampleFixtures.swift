import Foundation

struct CCDASampleFixtures {
    private init() {}

    static let expectedSampleFileNames = [
        "cerner-problems-medications.xml",
        "hl7-ccd.xml",
        "hl7-consults.xml",
        "hl7-diagnostic-imaging-report.xml",
        "hl7-discharge-summary.xml",
        "hl7-history-and-physical.xml",
        "hl7-operative-note.xml",
        "hl7-procedure-note.xml",
        "hl7-progress-note.xml",
        "hl7-unstructured-document.xml",
        "kareo-summary-of-care.xml",
        "local-comprehensive-sample.xml",
        "local-media-attachments.xml",
        "nist-ccd-ambulatory.xml",
        "partners-ccda.xml",
        "practicefusion-clinical-summary.xml",
        "toc-full.xml"
    ]

    static func ccdaSampleURLs() throws -> [URL] {
        try contentsOfDirectory(
            at: packageRootURL()
                .appendingPathComponent("test-data")
                .appendingPathComponent("ccda")
                .appendingPathComponent("samples"),
            includingPropertiesForKeys: [.fileSizeKey]
        )
        .filter { $0.pathExtension == "xml" }
        .sorted { $0.lastPathComponent < $1.lastPathComponent }
    }

    static func ccdaSampleURL(fileName: String) -> URL {
        packageRootURL()
            .appendingPathComponent("test-data")
            .appendingPathComponent("ccda")
            .appendingPathComponent("samples")
            .appendingPathComponent(fileName)
    }

    static func conformanceExpectedOutputURLs() throws -> [URL] {
        try contentsOfDirectory(
            at: packageRootURL()
                .appendingPathComponent("test-data")
                .appendingPathComponent("ccda")
                .appendingPathComponent("expected-output")
        )
        .filter { $0.pathExtension == "json" }
        .sorted { $0.lastPathComponent < $1.lastPathComponent }
    }

    static func conformanceExpectedOutputURL(for sampleURL: URL) -> URL {
        packageRootURL()
            .appendingPathComponent("test-data")
            .appendingPathComponent("ccda")
            .appendingPathComponent("expected-output")
            .appendingPathComponent(sampleURL.deletingPathExtension().lastPathComponent)
            .appendingPathExtension("json")
    }

    static func byteCount(for url: URL) -> Int {
        let values = try? url.resourceValues(forKeys: [.fileSizeKey])
        return values?.fileSize ?? 0
    }

    private static func packageRootURL() -> URL {
        let testFileURL = URL(fileURLWithPath: #filePath)
        return testFileURL
            .deletingLastPathComponent() // Support
            .deletingLastPathComponent() // CCDAEngineTests
            .deletingLastPathComponent() // Tests
            .deletingLastPathComponent() // apple
            .deletingLastPathComponent() // repo root
    }

    private static func contentsOfDirectory(
        at url: URL,
        includingPropertiesForKeys keys: [URLResourceKey]? = nil
    ) throws -> [URL] {
        try FileManager.default.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: keys
        )
    }
}
