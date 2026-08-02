import XCTest
@testable import CCDAEngine

final class CCDAMediaCacheTests: XCTestCase {
    func testInlineMediaStorageKeepsBase64Payload() throws {
        let engine = CCDAEngine(
            configuration: CCDAEngineConfiguration(
                mediaStoragePolicy: .inline,
                mediaCacheDirectory: nil
            )
        )

        let document = try engine.parse(data: Data(Self.mediaXML.utf8))
        let media = try XCTUnwrap(document.sections.first?.media.first)

        XCTAssertTrue(media.id.hasPrefix("m:"))
        XCTAssertEqual(media.mediaType, .textPlain)
        XCTAssertEqual(media.mediaType.mimeType, "text/plain")
        XCTAssertEqual(media.representation, .base64)
        XCTAssertEqual(try media.loadData(), Data("hello".utf8))
        XCTAssertFalse(media.isCached)

        guard case .inlineBase64(let value) = media.payload else {
            return XCTFail("Expected inline base64 payload.")
        }

        XCTAssertEqual(value, "aGVsbG8=")
    }

    func testMissingMediaMetadataMapsToUnknownEnums() throws {
        let engine = CCDAEngine(
            configuration: CCDAEngineConfiguration(
                mediaStoragePolicy: .inline,
                mediaCacheDirectory: nil
            )
        )

        let document = try engine.parse(data: Data(Self.mediaXMLWithoutMetadata.utf8))
        let media = try XCTUnwrap(document.sections.first?.media.first)

        XCTAssertEqual(media.mediaType, .unknown)
        XCTAssertNil(media.mediaType.mimeType)
        XCTAssertEqual(media.representation, .unknown)
        XCTAssertNil(media.representation.rawValue)
    }

    func testUnsupportedMediaMetadataPreservesRawValues() throws {
        let engine = CCDAEngine(
            configuration: CCDAEngineConfiguration(
                mediaStoragePolicy: .inline,
                mediaCacheDirectory: nil
            )
        )

        let document = try engine.parse(data: Data(Self.unsupportedMediaXML.utf8))
        let media = try XCTUnwrap(document.sections.first?.media.first)

        XCTAssertEqual(media.mediaType, .unsupported("application/dicom"))
        XCTAssertEqual(media.mediaType.mimeType, "application/dicom")
        XCTAssertEqual(media.representation, .unsupported("CUSTOM"))
        XCTAssertEqual(media.representation.rawValue, "CUSTOM")
    }

    func testDefaultMediaStorageWritesDecodedPayloadToDisk() throws {
        let document = try CCDAEngine().parse(data: Data(Self.mediaXML.utf8))
        let media = try XCTUnwrap(document.sections.first?.media.first)
        let cacheURL = try XCTUnwrap(media.payload.fileURL)

        XCTAssertTrue(media.id.hasPrefix("m:"))
        XCTAssertEqual(media.mediaType, .textPlain)
        XCTAssertEqual(media.representation, .base64)
        XCTAssertEqual(media.payload.byteCount, 5)
        XCTAssertEqual(try media.loadData(), Data("hello".utf8))
        XCTAssertTrue(media.isCached)
        XCTAssertTrue(FileManager.default.fileExists(atPath: cacheURL.path))
        XCTAssertTrue(cacheURL.deletingPathExtension().lastPathComponent.hasPrefix("m-"))
        XCTAssertEqual(cacheURL.pathExtension, "txt")
    }

    func testConfiguredMediaCacheDirectoryWritesDecodedPayloadToDisk() throws {
        let cacheDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        defer {
            try? FileManager.default.removeItem(at: cacheDirectory)
        }

        let engine = CCDAEngine(
            configuration: CCDAEngineConfiguration(
                mediaStoragePolicy: .cacheToDisk,
                mediaCacheDirectory: cacheDirectory
            )
        )

        let document = try engine.parse(data: Data(Self.mediaXML.utf8))
        let media = try XCTUnwrap(document.sections.first?.media.first)
        let cacheURL = try XCTUnwrap(media.payload.fileURL)

        XCTAssertTrue(media.id.hasPrefix("m:"))
        XCTAssertEqual(media.mediaType, .textPlain)
        XCTAssertEqual(media.representation, .base64)
        XCTAssertEqual(media.payload.byteCount, 5)
        XCTAssertEqual(try media.loadData(), Data("hello".utf8))
        XCTAssertTrue(media.isCached)
        XCTAssertTrue(FileManager.default.fileExists(atPath: cacheURL.path))
        XCTAssertTrue(cacheURL.deletingPathExtension().lastPathComponent.hasPrefix("m-"))
        XCTAssertEqual(cacheURL.pathExtension, "txt")
    }

    private static let mediaXML = """
    <?xml version="1.0" encoding="UTF-8"?>
    <ClinicalDocument xmlns="urn:hl7-org:v3">
        <id root="1.2.3" extension="doc-1"/>
        <code code="34133-9"/>
        <title>Media Sample</title>
        <recordTarget>
            <patientRole>
                <patient>
                    <name><given>Jane</given><family>Doe</family></name>
                    <birthTime value="19800101"/>
                </patient>
            </patientRole>
        </recordTarget>
        <component>
            <structuredBody>
                <component>
                    <section>
                        <code code="55109-3" displayName="Media"/>
                        <title>Media</title>
                        <text>Embedded media sample</text>
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

    private static let mediaXMLWithoutMetadata = mediaXML
        .replacingOccurrences(of: #" mediaType="text/plain" representation="B64""#, with: "")

    private static let unsupportedMediaXML = mediaXML
        .replacingOccurrences(of: #"mediaType="text/plain""#, with: #"mediaType="application/dicom""#)
        .replacingOccurrences(of: #"representation="B64""#, with: #"representation="CUSTOM""#)
}
