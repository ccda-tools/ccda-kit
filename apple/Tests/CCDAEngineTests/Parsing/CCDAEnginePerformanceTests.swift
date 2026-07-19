import XCTest
@testable import CCDAEngine

final class CCDAEnginePerformanceTests: XCTestCase {
    func testParseAllSharedCCDASamplesPerformance() throws {
        let sampleData = try CCDASampleFixtures.ccdaSampleURLs().map { url in
            try SampleDocument(name: url.lastPathComponent, data: Data(contentsOf: url))
        }

        XCTAssertFalse(sampleData.isEmpty, "Expected sample C-CDA files in test-data/ccda.")

        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            let engine = CCDAEngine()

            for sample in sampleData {
                do {
                    _ = try engine.parse(data: sample.data)
                } catch {
                    XCTFail("Failed to parse \(sample.name): \(error)")
                }
            }
        }
    }

    func testParseLargestSharedCCDASamplePerformance() throws {
        let largestSampleURL = try CCDASampleFixtures.ccdaSampleURLs()
            .max { lhs, rhs in
                CCDASampleFixtures.byteCount(for: lhs) < CCDASampleFixtures.byteCount(for: rhs)
            }

        let url = try XCTUnwrap(largestSampleURL, "Expected sample C-CDA files in test-data/ccda.")
        let data = try Data(contentsOf: url)

        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            do {
                _ = try CCDAEngine().parse(data: data)
            } catch {
                XCTFail("Failed to parse \(url.lastPathComponent): \(error)")
            }
        }
    }
}

private struct SampleDocument {
    let name: String
    let data: Data
}
