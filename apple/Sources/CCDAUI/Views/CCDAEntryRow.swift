import SwiftUI
import CCDAEngine

/// Default row renderer for a structured C-CDA entry.
public struct CCDAEntryRow: View {
    /// Entry to render.
    public let entry: CCDAEntry

    /// Creates an entry row.
    public init(entry: CCDAEntry) {
        self.entry = entry
    }

    /// SwiftUI view body.
    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.code?.displayName ?? entry.code?.code ?? entry.type)
                .font(.headline)

            if let status = entry.status {
                Text("Status: \(status)")
                    .font(.subheadline)
            }

            if let effectiveTime = entry.effectiveTime {
                Text("Time: \(effectiveTime.formattedDateTime)")
                    .font(.subheadline)
            }

            if let value = entry.value {
                Text(value.formattedValue)
                    .font(.subheadline)
            }

            ForEach(entry.children) { child in
                CCDAEntryRow(entry: child)
                    .padding(.leading, 12)
            }
        }
        .padding(.vertical, 4)
    }
}
