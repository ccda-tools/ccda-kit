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

            VStack(alignment: .leading) {
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

                let details = CCDAEntryDetail.flattened(from: entry.children)
                if !details.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(details) { detail in
                            CCDAEntryDetailRow(detail: detail)
                        }
                    }
                    .padding(.top, 4)
                }
            }
            .padding(.leading, 24)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CCDATheme.rowBackground)
        .clipShape(RoundedRectangle(cornerRadius: CCDATheme.cornerRadius, style: .continuous))
    }
}

private struct CCDAEntryDetail: Identifiable {
    let id: String
    let title: String
    let value: String?
    let status: String?
    let time: String?

    static func flattened(from entries: [CCDAEntry]) -> [CCDAEntryDetail] {
        entries.flatMap { entry in
            [
                CCDAEntryDetail(
                    id: entry.id,
                    title: entry.code?.displayName ?? entry.code?.code ?? entry.type.rawValue,
                    value: entry.value?.formattedValue,
                    status: entry.status?.rawValue,
                    time: entry.effectiveTime?.formattedDateTime
                )
            ] + flattened(from: entry.children)
        }
    }
}

private struct CCDAEntryDetailRow: View {
    let detail: CCDAEntryDetail

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(detail.title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary)

                if let value = detail.value, !value.isEmpty {
                    Text(value)
                        .font(.caption)
                        .foregroundStyle(.primary)
                }
            }

            ViewThatFits(in: .horizontal) {
                HStack(spacing: 8) {
                    CCDAEntryDetailMetadata(detail: detail)
                }

                VStack(alignment: .leading, spacing: 1) {
                    CCDAEntryDetailMetadata(detail: detail)
                }
            }
        }
        .padding(.leading, 10)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(CCDATheme.secondary.opacity(0.32))
                .frame(width: 2)
        }
    }
}

private struct CCDAEntryDetailMetadata: View {
    let detail: CCDAEntryDetail

    var body: some View {
        if let status = detail.status {
            CCDAEntryMetadata(label: "Status", value: status)
        }

        if let time = detail.time {
            CCDAEntryMetadata(label: "Time", value: time)
        }
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
