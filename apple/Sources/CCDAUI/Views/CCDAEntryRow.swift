import SwiftUI
import CCDAEngine

public struct CCDAEntryRow: View {
    public let entry: CCDAEntry

    public init(entry: CCDAEntry) {
        self.entry = entry
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.code?.displayName ?? entry.code?.code ?? entry.type)
                .font(.headline)

            if let status = entry.status {
                Text("Status: \(status)")
                    .font(.subheadline)
            }

            if let effectiveTime = entry.effectiveTime {
                Text("Time: \(effectiveTime)")
                    .font(.subheadline)
            }

            if let value = entry.value {
                Text(value.display)
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
