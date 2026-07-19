import XCTest
@testable import CCDAEngine
@testable import CCDAUI

final class CCDAValueFormattingTests: XCTestCase {
    func testFormattedValuePrefersDisplayNameThenValueAndUnit() {
        XCTAssertEqual(
            CCDAValue(
                type: "CD",
                code: "123",
                displayName: "Hypertension",
                value: "120",
                unit: "mm[Hg]"
            ).formattedValue,
            "Hypertension"
        )

        XCTAssertEqual(
            CCDAValue(
                type: "PQ",
                value: "120",
                unit: "mm[Hg]"
            ).formattedValue,
            "120 mm[Hg]"
        )

        XCTAssertEqual(CCDAValue().formattedValue, "")
    }
}
