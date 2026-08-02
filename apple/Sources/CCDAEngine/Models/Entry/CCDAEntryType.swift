import Foundation

/// XML element type for a structured C-CDA entry.
public enum CCDAEntryType: Hashable, Sendable {
    /// CDA act entry.
    case act
    /// CDA encounter entry.
    case encounter
    /// CDA observation entry.
    case observation
    /// CDA organizer entry.
    case organizer
    /// CDA procedure entry.
    case procedure
    /// CDA substanceAdministration entry.
    case substanceAdministration
    /// CDA supply entry.
    case supply
    /// Unsupported entry element name preserved from source XML.
    case unsupported(String)

    /// Creates an entry type from an XML element name.
    public init(elementName: String) {
        switch elementName {
        case "act":
            self = .act
        case "encounter":
            self = .encounter
        case "observation":
            self = .observation
        case "organizer":
            self = .organizer
        case "procedure":
            self = .procedure
        case "substanceAdministration":
            self = .substanceAdministration
        case "supply":
            self = .supply
        default:
            self = .unsupported(elementName)
        }
    }

    /// Original XML element name.
    public var rawValue: String {
        switch self {
        case .act:
            return "act"
        case .encounter:
            return "encounter"
        case .observation:
            return "observation"
        case .organizer:
            return "organizer"
        case .procedure:
            return "procedure"
        case .substanceAdministration:
            return "substanceAdministration"
        case .supply:
            return "supply"
        case .unsupported(let rawValue):
            return rawValue
        }
    }
}
