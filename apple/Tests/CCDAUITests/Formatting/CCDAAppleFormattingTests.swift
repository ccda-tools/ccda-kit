import Contacts
import XCTest
@testable import CCDAEngine
@testable import CCDAUI

final class CCDAAppleFormattingTests: XCTestCase {
    func testHumanNameProvidesAppleNameComponents() {
        let name = CCDAHumanName(prefix: "Dr.", given: ["Alex", "Morgan"], family: "Rivera")

        let components = name.personNameComponents

        XCTAssertEqual(components.namePrefix, "Dr.")
        XCTAssertEqual(components.givenName, "Alex")
        XCTAssertEqual(components.middleName, "Morgan")
        XCTAssertEqual(components.familyName, "Rivera")
    }

    func testAddressProvidesPostalAddress() {
        let address = CCDAAddress(
            use: "HP",
            streetLines: ["123 Main St", "Apt 4B"],
            city: "Boston",
            state: "MA",
            postalCode: "02118",
            country: "US"
        )

        let postalAddress = address.postalAddress

        XCTAssertEqual(postalAddress.street, "123 Main St\nApt 4B")
        XCTAssertEqual(postalAddress.city, "Boston")
        XCTAssertEqual(postalAddress.state, "MA")
        XCTAssertEqual(postalAddress.postalCode, "02118")
        XCTAssertEqual(postalAddress.country, "US")
    }
}
