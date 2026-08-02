import Foundation

/// Main parser entry point for converting C-CDA XML into normalized models.
public final class CCDAEngine: Sendable {
    private let configuration: CCDAEngineConfiguration

    /// Creates a parser with the provided configuration.
    public init(configuration: CCDAEngineConfiguration = .default) {
        self.configuration = configuration
    }

    /// Parses C-CDA XML from in-memory data.
    public func parse(data: Data) throws -> CCDADocument {
        let temporaryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("ccda-kit-\(UUID().uuidString)")
            .appendingPathExtension("xml")
        try data.write(to: temporaryURL, options: .atomic)
        defer { try? FileManager.default.removeItem(at: temporaryURL) }
        return try parse(url: temporaryURL, sourceDescription: nil)
    }

    /// Parses C-CDA XML from a file URL.
    public func parse(url: URL) throws -> CCDADocument {
        try parse(url: url, sourceDescription: url.path)
    }

    /// Parses C-CDA XML from an input stream.
    public func parse(stream: InputStream) throws -> CCDADocument {
        try parse(stream: stream, sourceDescription: nil)
    }

    private func parse(url: URL, sourceDescription: String?) throws -> CCDADocument {
        guard let stream = InputStream(url: url) else {
            throw CCDAEngineError.invalidXML(
                CCDAXMLParsingFailure(
                    message: "Unable to open XML input stream.",
                    sourceDescription: sourceDescription
                )
            )
        }
        return try parse(stream: stream, sourceDescription: sourceDescription)
    }

    private func parse(stream: InputStream, sourceDescription: String?) throws -> CCDADocument {
        let mapper = CCDADocumentMapper(configuration: configuration)

        let streamBuilder = XMLStreamingDocumentBuilder { sectionNode, sectionIndex in
            try mapper.mapSection(sectionNode, sectionIndex: sectionIndex)
        }

        let parser = XMLParser(stream: stream)
        parser.delegate = streamBuilder
        parser.shouldProcessNamespaces = true

        guard parser.parse(), let root = streamBuilder.root else {
            if let mappingError = streamBuilder.mappingError {
                throw mappingError
            }

            throw CCDAEngineError.invalidXML(
                xmlParsingFailure(
                    from: parser,
                    sourceDescription: sourceDescription,
                    hasRootNode: streamBuilder.root != nil
                )
            )
        }

        return try mapper.map(root: root, sections: streamBuilder.sections)
    }

    /// Builds a consistent engine error from Foundation XMLParser state.
    private func xmlParsingFailure(
        from parser: XMLParser,
        sourceDescription: String?,
        hasRootNode: Bool
    ) -> CCDAXMLParsingFailure {
        let underlyingError = parser.parserError
        let message = underlyingError?.localizedDescription
            ?? (hasRootNode ? "XML parser stopped before completing the document." : "No root XML element was found.")

        return CCDAXMLParsingFailure(
            message: message,
            lineNumber: positive(parser.lineNumber),
            columnNumber: positive(parser.columnNumber),
            sourceDescription: sourceDescription,
            underlyingErrorDescription: underlyingError?.localizedDescription
        )
    }

    /// Converts non-positive parser positions into nil.
    private func positive(_ value: Int) -> Int? {
        value > 0 ? value : nil
    }
}
