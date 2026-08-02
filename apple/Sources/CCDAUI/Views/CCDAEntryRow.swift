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
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Image(systemName: "waveform.path.ecg")
                    .font(.caption)
                    .foregroundStyle(CCDATheme.secondary)

                Text(entry.code?.displayName ?? entry.code?.code ?? entry.type.rawValue)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
            }

            if let status = entry.status {
                CCDAEntryMetadata(label: "Status", value: status.rawValue)
            }

            if let effectiveTime = entry.effectiveTime {
                CCDAEntryMetadata(label: "Time", value: effectiveTime.formattedDateTime)
            }

            if let value = entry.value {
                Text(value.formattedValue)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            }

            ForEach(entry.children) { child in
                CCDAEntryRow(entry: child)
                    .padding(.leading, 12)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CCDATheme.rowBackground)
        .clipShape(RoundedRectangle(cornerRadius: CCDATheme.cornerRadius, style: .continuous))
    }
}

private struct CCDAEntryMetadata: View {
    let label: String
    let value: String

    var body: some View {
        Text("\(label): \(value)")
            .font(.caption)
            .foregroundStyle(.secondary)
    }
}
