import Foundation
import CCDAEngine

public extension CCDAValue {
    /// Default text used by `CCDAUI` when rendering a value.
    var formattedValue: String {
        if let displayName {
            return displayName
        }

        return [value, unit].compactMap { $0 }.joined(separator: " ")
    }
}
