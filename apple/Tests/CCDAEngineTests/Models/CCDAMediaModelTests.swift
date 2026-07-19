import Foundation
import XCTest
@testable import CCDAEngine

final class CCDAMediaModelTests: XCTestCase {
    func testMediaTypeMapsKnownMimeTypesCaseInsensitively() {
        XCTAssertEqual(CCDAMediaType(mimeType: "image/png"), .imagePNG)
        XCTAssertEqual(CCDAMediaType(mimeType: "IMAGE/JPEG"), .imageJPEG)
        XCTAssertEqual(CCDAMediaType(mimeType: "image/jpg"), .imageJPEG)
        XCTAssertEqual(CCDAMediaType(mimeType: "image/gif"), .imageGIF)
        XCTAssertEqual(CCDAMediaType(mimeType: "application/pdf"), .applicationPDF)
        XCTAssertEqual(CCDAMediaType(mimeType: "text/plain"), .textPlain)
        XCTAssertEqual(CCDAMediaType(mimeType: "text/html"), .textHTML)
    }

    func testMediaTypePreservesUnsupportedAndUnknownMimeTypes() {
        XCTAssertEqual(CCDAMediaType(mimeType: "application/dicom"), .unsupported("application/dicom"))
        XCTAssertEqual(CCDAMediaType(mimeType: nil), .unknown)
        XCTAssertEqual(CCDAMediaType(mimeType: ""), .unknown)
        XCTAssertEqual(CCDAMediaType.unsupported("application/dicom").mimeType, "application/dicom")
        XCTAssertNil(CCDAMediaType.unknown.mimeType)
    }

    func testImageDetectionOnlyMatchesImageMimeTypes() {
        XCTAssertTrue(CCDAMediaType.imagePNG.isImage)
        XCTAssertTrue(CCDAMediaType.imageJPEG.isImage)
        XCTAssertTrue(CCDAMediaType.imageGIF.isImage)
        XCTAssertFalse(CCDAMediaType.applicationPDF.isImage)
        XCTAssertFalse(CCDAMediaType.textPlain.isImage)
        XCTAssertFalse(CCDAMediaType.unknown.isImage)
    }

    func testMediaRepresentationMapsKnownRawValuesCaseInsensitively() {
        XCTAssertEqual(CCDAMediaRepresentation(rawValue: "B64"), .base64)
        XCTAssertEqual(CCDAMediaRepresentation(rawValue: "b64"), .base64)
        XCTAssertEqual(CCDAMediaRepresentation(rawValue: "TXT"), .text)
        XCTAssertEqual(CCDAMediaRepresentation(rawValue: "txt"), .text)
        XCTAssertEqual(CCDAMediaRepresentation(rawValue: "CUSTOM"), .unsupported("CUSTOM"))
        XCTAssertEqual(CCDAMediaRepresentation(rawValue: nil), .unknown)
        XCTAssertEqual(CCDAMediaRepresentation(rawValue: ""), .unknown)
        XCTAssertEqual(CCDAMediaRepresentation.base64.rawValue, "B64")
        XCTAssertEqual(CCDAMediaRepresentation.text.rawValue, "TXT")
        XCTAssertNil(CCDAMediaRepresentation.unknown.rawValue)
    }

    func testInlineMediaLoadDataStripsWhitespaceBeforeDecoding() throws {
        let media = CCDAMedia(
            id: "media-1",
            mediaType: .textPlain,
            representation: .base64,
            payload: .inlineBase64("aG Vs\nbG8=")
        )

        XCTAssertEqual(try media.loadData(), Data("hello".utf8))
        XCTAssertFalse(media.isCached)
        XCTAssertFalse(media.isImage)
    }

    func testInvalidInlineBase64ThrowsTypedError() {
        let media = CCDAMedia(
            id: "media-1",
            mediaType: .textPlain,
            representation: .base64,
            payload: .inlineBase64("not base64")
        )

        XCTAssertThrowsError(try media.loadData()) { error in
            XCTAssertEqual(error as? CCDAMediaPayloadError, .invalidBase64)
        }
    }

    func testUnavailablePayloadThrowsTypedError() {
        let media = CCDAMedia(
            id: "media-1",
            mediaType: .unknown,
            representation: .unknown,
            payload: .unavailable
        )

        XCTAssertThrowsError(try media.loadData()) { error in
            XCTAssertEqual(error as? CCDAMediaPayloadError, .unavailable)
        }
    }

    func testCachedPayloadExposesFileURLAndByteCount() throws {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try Data("cached".utf8).write(to: fileURL)
        defer { try? FileManager.default.removeItem(at: fileURL) }

        let media = CCDAMedia(
            id: "media-1",
            mediaType: .textPlain,
            representation: .base64,
            payload: .cachedFile(fileURL, byteCount: 6)
        )

        XCTAssertEqual(media.payload.fileURL, fileURL)
        XCTAssertEqual(media.payload.byteCount, 6)
        XCTAssertEqual(try media.loadData(), Data("cached".utf8))
        XCTAssertTrue(media.isCached)
    }
}
