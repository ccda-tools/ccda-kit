import Testing
@testable import CCDAEngine

struct CCDASampleCorpusTests {
    @Test
    func sharedCCDASampleCorpusMatchesExpectedInventory() throws {
        let sampleFileNames = try CCDASampleFixtures.ccdaSampleURLs().map(\.lastPathComponent)

        #expect(sampleFileNames == CCDASampleFixtures.expectedSampleFileNames)
    }

    @Test
    func everyCCDASampleHasExpectedConformanceOutput() throws {
        let sampleBaseNames = Set(
            try CCDASampleFixtures.ccdaSampleURLs()
                .map { $0.deletingPathExtension().lastPathComponent }
        )
        let expectedOutputBaseNames = Set(
            try CCDASampleFixtures.conformanceExpectedOutputURLs()
                .map { $0.deletingPathExtension().lastPathComponent }
        )

        #expect(sampleBaseNames == expectedOutputBaseNames)
    }

    @Test(arguments: CCDASampleFixtures.expectedSampleFileNames)
    func ccdaSampleParsesWithMeaningfulClinicalData(fileName: String) throws {
        let document = try CCDAEngine().parse(url: CCDASampleFixtures.ccdaSampleURL(fileName: fileName))

        #expect(!document.header.documentId.display.isEmpty)
        #expect(document.header.code?.code != nil)
        #expect(document.patient != nil)
        #expect(document.patient?.name?.display != nil)
        #expect(document.patient?.birthTime != nil)

        for section in document.sections {
            #expect(section.title != nil || section.code != nil)
            #expect(!section.narrativeText.isEmpty || !section.entries.isEmpty || !section.media.isEmpty)
        }
    }

    @Test
    func sharedCCDASampleCorpusHasBroadClinicalCoverage() throws {
        let sampleURLs = try CCDASampleFixtures.ccdaSampleURLs()
        let engine = CCDAEngine()
        var structuredDocumentCount = 0
        var totalSectionCount = 0
        var totalEntryCount = 0
        var sectionCodes = Set<String>()
        var documentCodes = Set<String>()

        for url in sampleURLs {
            let document = try engine.parse(url: url)

            if let documentCode = document.header.code?.code {
                documentCodes.insert(documentCode)
            }

            if !document.sections.isEmpty {
                structuredDocumentCount += 1
            }

            totalSectionCount += document.sections.count

            for section in document.sections {
                totalEntryCount += section.entries.count

                if let sectionCode = section.code?.code {
                    sectionCodes.insert(sectionCode)
                }
            }
        }

        #expect(structuredDocumentCount >= sampleURLs.count - 1)
        #expect(totalSectionCount >= 150)
        #expect(totalEntryCount >= 100)
        #expect(documentCodes.count >= 8)
        #expect(sectionCodes.count >= 30)
    }
}
