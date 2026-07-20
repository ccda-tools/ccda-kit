//
//  ContentView.swift
//  Example
//
//  Created by Shahzaib Iqbal on 7/3/26.
//

import SwiftUI
import CCDAEngine
import CCDAUI

private let ccdaExamples: [CCDAExample] = [
    CCDAExample(title: "Local Comprehensive Sample", filename: "local-comprehensive-sample", source: "Shared Test Data"),
    CCDAExample(title: "Media Attachments", filename: "local-media-attachments", source: "Shared Test Data"),
    CCDAExample(title: "HL7 CCD", filename: "hl7-ccd", source: "HL7 Samples"),
    CCDAExample(title: "HL7 Discharge Summary", filename: "hl7-discharge-summary", source: "HL7 Samples"),
    CCDAExample(title: "HL7 Progress Note", filename: "hl7-progress-note", source: "HL7 Samples"),
    CCDAExample(title: "Cerner Problems and Medications", filename: "cerner-problems-medications", source: "Cerner Samples"),
    CCDAExample(title: "Transition of Care Full XML", filename: "toc-full", source: "Transitions of Care Samples")
]

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List(ccdaExamples) { example in
                NavigationLink(value: example) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(example.title)
                            .font(.headline)
                        Text(example.source)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("CCDA Examples")
            .navigationDestination(for: CCDAExample.self) { example in
                CCDAExampleDetailView(example: example)
            }
        }
    }
}

private struct CCDAExampleDetailView: View {
    let example: CCDAExample
    @State private var loadState: LoadState = .loading

    var body: some View {
        Group {
            switch loadState {
            case .loading:
                ProgressView("Loading CCDA")
            case .loaded(let document):
                CCDADocumentView(document: document)
            case .failed(let message):
                ContentUnavailableView(
                    "Unable to Load CCDA",
                    systemImage: "doc.text.magnifyingglass",
                    description: Text(message)
                )
            }
        }
        .navigationTitle(example.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            loadDocument()
        }
    }

    private func loadDocument() {
        guard case .loading = loadState else {
            return
        }

        guard let url = Bundle.main.url(
            forResource: example.filename,
            withExtension: "xml",
            subdirectory: "CCDAExamples"
        ) else {
            loadState = .failed(missingResourceMessage(for: example.filename))
            return
        }

        do {
            let document = try CCDAEngine().parse(url: url)
            loadState = .loaded(document)
        } catch {
            loadState = .failed(error.localizedDescription)
        }
    }

    private func missingResourceMessage(for filename: String) -> String {
        let availableFiles = (try? FileManager.default.contentsOfDirectory(
            at: Bundle.main.bundleURL.appendingPathComponent("CCDAExamples"),
            includingPropertiesForKeys: nil
        ))?
            .filter { $0.pathExtension == "xml" }
            .map(\.lastPathComponent)
            .sorted()
            .joined(separator: ", ")

        return """
        \(filename).xml was not found in the app bundle.

        Bundle path: \(Bundle.main.bundleURL.appendingPathComponent("CCDAExamples").path)
        XML files in bundle: \(availableFiles?.isEmpty == false ? availableFiles! : "none")
        """
    }
}

private struct CCDAExample: Identifiable, Hashable {
    var id: String { filename }
    let title: String
    let filename: String
    let source: String
}

private enum LoadState {
    case loading
    case loaded(CCDADocument)
    case failed(String)
}

#Preview {
    ContentView()
}
