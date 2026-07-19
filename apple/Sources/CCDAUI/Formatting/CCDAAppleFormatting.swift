import Contacts
import Foundation
import CCDAEngine

public extension CCDAHumanName {
    /// Name components suitable for Apple name formatters.
    var personNameComponents: PersonNameComponents {
        var components = PersonNameComponents()
        components.namePrefix = prefix
        components.givenName = given.first
        let middleNames = given.dropFirst()
        components.middleName = middleNames.isEmpty ? nil : middleNames.joined(separator: " ")
        components.familyName = family
        return components
    }

    /// Localized display name using Apple's name formatter.
    var formattedName: String {
        PersonNameComponentsFormatter.localizedString(
            from: personNameComponents,
            style: .medium,
            options: []
        )
    }
}

public extension CCDAAddress {
    /// Postal address suitable for Apple's address formatter.
    var postalAddress: CNPostalAddress {
        let address = CNMutablePostalAddress()
        address.street = streetLines.joined(separator: "\n")
        address.city = city ?? ""
        address.state = state ?? ""
        address.postalCode = postalCode ?? ""
        address.country = country ?? ""
        return address
    }

    /// Localized mailing address using Apple's postal address formatter.
    var formattedPostalAddress: String {
        CNPostalAddressFormatter.string(from: postalAddress, style: .mailingAddress)
    }
}
