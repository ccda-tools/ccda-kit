import XCTest
@testable import CCDAEngine
@testable import CCDAUI

final class CCDATimestampFormattingTests: XCTestCase {
    func testFormatsDateOnlyTimestampWithoutTime() throws {
        let timestamp = try XCTUnwrap(CCDATimestamp(rawValue: "19800515"))

        XCTAssertEqual(timestamp.formattedDateTime, "May 15, 1980")
    }

    func testFormatsTimestampWithTimeAndTimeZone() throws {
        let timestamp = try XCTUnwrap(CCDATimestamp(rawValue: "20260719093045-0500"))

        XCTAssertEqual(timestamp.formattedDateTime, "Jul 19, 2026 at 9:30:45 AM UTC-05:00")
    }

    func testFormatsYearAndMonthOnlyTimestamp() throws {
        let timestamp = try XCTUnwrap(CCDATimestamp(rawValue: "202607"))

        XCTAssertEqual(timestamp.formattedDateTime, "Jul 2026")
    }
}
