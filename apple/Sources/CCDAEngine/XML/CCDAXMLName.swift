import Foundation

/// XML element names used by the C-CDA mapper.
enum CCDAXMLElement: String, Sendable {
    case administrativeGenderCode
    case addr
    case birthTime
    case city
    case code
    case component
    case confidentialityCode
    case country
    case effectiveTime
    case entry
    case entryRelationship
    case ethnicGroupCode
    case family
    case given
    case high
    case id
    case languageCode
    case low
    case maritalStatusCode
    case name
    case observationMedia
    case patient
    case patientRole
    case postalCode
    case prefix
    case raceCode
    case realmCode
    case recordTarget
    case reference
    case section
    case state
    case statusCode
    case streetAddressLine
    case structuredBody
    case telecom
    case templateId
    case text
    case title
    case typeId
    case value
}

/// XML attribute names used by the C-CDA mapper.
enum CCDAXMLAttribute: String, Sendable {
    case code
    case codeSystem
    case codeSystemName
    case displayName
    case `extension` = "extension"
    case id = "ID"
    case mediaType
    case representation
    case root
    case type
    case unit
    case use
    case value
    case xsiType = "xsi:type"
}
