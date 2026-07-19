import XCTest
@testable import CCDAEngine

final class CCDATimestampTests: XCTestCase {
    func testParsesHL7TimestampComponentsByPosition() throws {
        let timestamp = try XCTUnwrap(CCDATimestamp(rawValue: "20260719093045.123-0500"))

        XCTAssertEqual(timestamp.rawValue, "20260719093045.123-0500")
        XCTAssertEqual(timestamp.year, 2026)
        XCTAssertEqual(timestamp.month, 7)
        XCTAssertEqual(timestamp.day, 19)
        XCTAssertEqual(timestamp.hour, 9)
        XCTAssertEqual(timestamp.minute, 30)
        XCTAssertEqual(timestamp.second, 45)
        XCTAssertEqual(timestamp.fractionalSecond, "123")
        XCTAssertEqual(timestamp.timeZoneOffset, "-0500")
    }

    func testParsesPartialDatesWithoutInventingTime() throws {
        let timestamp = try XCTUnwrap(CCDATimestamp(rawValue: "19800515"))

        XCTAssertEqual(timestamp.year, 1980)
        XCTAssertEqual(timestamp.month, 5)
        XCTAssertEqual(timestamp.day, 15)
        XCTAssertNil(timestamp.hour)
        XCTAssertFalse(timestamp.hasTime)
    }

    func testReturnsNilWhenYearCannotBeParsed() {
        XCTAssertNil(CCDATimestamp(rawValue: "bad-date"))
        XCTAssertNil(CCDATimestamp(rawValue: "123"))
        XCTAssertNil(CCDATimestamp(rawValue: "00000515"))
    }
}
