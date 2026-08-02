import Foundation

/// HL7 address use code from a C-CDA addr element.
public enum CCDAAddressUse: Hashable, Sendable {
    /// Home address, represented by H.
    case home
    /// Primary home address, represented by HP.
    case primaryHome
    /// Work place address, represented by WP.
    case workPlace
    /// Temporary address, represented by TMP.
    case temporary
    /// Old or inactive address, represented by OLD.
    case old
    /// Bad address, represented by BAD.
    case bad
    /// Unrecognized address use code preserved from the source document.
    case unsupported(String)
    /// Missing address use code.
    case unknown

    /// Creates an address use from an HL7 code.
    public init(code: String?) {
        guard let code, !code.isEmpty else {
            self = .unknown
            return
        }

        switch code.uppercased() {
        case "H":
            self = .home
        case "HP":
            self = .primaryHome
        case "WP":
            self = .workPlace
        case "TMP":
            self = .temporary
        case "OLD":
            self = .old
        case "BAD":
            self = .bad
        default:
            self = .unsupported(code)
        }
    }

    /// HL7 source code when known.
    public var code: String? {
        switch self {
        case .home:
            return "H"
        case .primaryHome:
            return "HP"
        case .workPlace:
            return "WP"
        case .temporary:
            return "TMP"
        case .old:
            return "OLD"
        case .bad:
            return "BAD"
        case .unsupported(let code):
            return code
        case .unknown:
            return nil
        }
    }
}
