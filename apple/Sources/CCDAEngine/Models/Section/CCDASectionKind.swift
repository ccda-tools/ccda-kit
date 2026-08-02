import Foundation

/// Known C-CDA section categories identified from standard section codes.
public enum CCDASectionKind: Hashable, Sendable {
    /// Allergies, adverse reactions, alerts, or intolerances section.
    case allergies
    /// Assessment section.
    case assessment
    /// Care plan or plan of treatment section.
    case planOfCare
    /// Encounters section.
    case encounters
    /// Functional status section.
    case functionalStatus
    /// Immunizations section.
    case immunizations
    /// Medical equipment section.
    case medicalEquipment
    /// Medications section.
    case medications
    /// Payers section.
    case payers
    /// Problem list section.
    case problems
    /// Procedures section.
    case procedures
    /// Reason for referral section.
    case reasonForReferral
    /// Results section.
    case results
    /// Social history section.
    case socialHistory
    /// Vital signs section.
    case vitalSigns
    /// Unknown or vendor-specific section code.
    case unknown(code: String?)

    /// Creates a section kind from the C-CDA section code.
    public init(code: String?) {
        switch code {
        case "48765-2":
            self = .allergies
        case "51848-0":
            self = .assessment
        case "18776-5", "61146-7":
            self = .planOfCare
        case "46240-8":
            self = .encounters
        case "47420-5":
            self = .functionalStatus
        case "11369-6":
            self = .immunizations
        case "46264-8":
            self = .medicalEquipment
        case "10160-0":
            self = .medications
        case "48768-6":
            self = .payers
        case "11450-4":
            self = .problems
        case "47519-4":
            self = .procedures
        case "42349-1":
            self = .reasonForReferral
        case "30954-2":
            self = .results
        case "29762-2":
            self = .socialHistory
        case "8716-3":
            self = .vitalSigns
        default:
            self = .unknown(code: code)
        }
    }
}
