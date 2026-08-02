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
        try parse(data: data, sourceDescription: nil)
    }

    /// Parses C-CDA XML from a file URL.
    public func parse(url: URL) throws -> CCDADocument {
        try parse(data: Data(contentsOf: url), sourceDescription: url.path)
    }

    private func parse(data: Data, sourceDescription: String?) throws -> CCDADocument {
        let domBuilder = XMLDOMBuilder()
        let parser = XMLParser(data: data)
        parser.delegate = domBuilder
        parser.shouldProcessNamespaces = true

        guard parser.parse(), let root = domBuilder.root else {
            throw CCDAEngineError.invalidXML(
                xmlParsingFailure(
                    from: parser,
                    sourceDescription: sourceDescription,
                    hasRootNode: domBuilder.root != nil
                )
            )
        }

        return try mapDocument(root)
    }

    private func mapDocument(_ root: CCDAXMLNode) throws -> CCDADocument {
        let header = CCDAHeader(
            realmCode: root.first(.realmCode)?.attribute(.code),
            typeId: root.first(.typeId).map(identifier),
            templateIds: root.direct(.templateId).map(templateId),
            documentId: root.first(.id).map(identifier) ?? CCDAIdentifier(root: nil, extensionValue: nil),
            code: root.first(.code).map(codedValue),
            title: root.first(.title)?.cleanText,
            effectiveTime: timestamp(root.first(.effectiveTime)?.attribute(.value)),
            confidentialityCode: root.first(.confidentialityCode).map(codedValue),
            languageCode: root.first(.languageCode)?.attribute(.code)
        )

        return CCDADocument(
            header: header,
            patient: mapPatient(root),
            sections: try mapSections(root)
        )
    }

    /// Maps patient demographics from recordTarget.
    private func mapPatient(_ root: CCDAXMLNode) -> CCDAPatient? {
        guard let patientRole = root.first(.recordTarget)?.first(.patientRole) else {
            return nil
        }

        let patient = patientRole.first(.patient)

        return CCDAPatient(
            ids: patientRole.direct(.id).map(identifier),
            name: patient?.first(.name).map(humanName),
            gender: patient?.first(.administrativeGenderCode).map(codedValue),
            birthTime: timestamp(patient?.first(.birthTime)?.attribute(.value)),
            maritalStatus: patient?.first(.maritalStatusCode).map(codedValue),
            race: patient?.first(.raceCode).map(codedValue),
            ethnicity: patient?.first(.ethnicGroupCode).map(codedValue),
            addresses: patientRole.direct(.addr).map(address),
            telecoms: patientRole.direct(.telecom).compactMap { $0.attribute(.value) }
        )
    }

    /// Maps structuredBody components into renderable sections.
    private func mapSections(_ root: CCDAXMLNode) throws -> [CCDASection] {
        guard let structuredBody = root.first(.component)?.first(.structuredBody) else {
            return []
        }

        return try structuredBody.direct(.component).enumerated().compactMap { sectionIndex, component in
            guard let section = component.first(.section) else { return nil }
            let code = section.first(.code).map(codedValue)
            let title = section.first(.title)?.cleanText
            let mediaNodes = section.direct(.entry).flatMap { entry in
                entry.children.filter { $0.isNamed(.observationMedia) }
            }
            return CCDASection(
                id: CCDAStableID.section(index: sectionIndex, code: code?.code, title: title),
                templateIds: section.direct(.templateId).map(templateId),
                code: code,
                kind: CCDASectionKind(code: code?.code),
                title: title,
                narrativeText: section.first(.text)?.cleanText ?? "",
                entries: section.direct(.entry).enumerated().flatMap { entryIndex, entry in
                    entry.children
                        .filter { !$0.isNamed(.observationMedia) }
                        .enumerated()
                        .map { childIndex, child in
                            mapEntry(
                                child,
                                path: [String(sectionIndex), String(entryIndex), String(childIndex)]
                            )
                        }
                },
                media: try mediaNodes.enumerated().compactMap { mediaIndex, mediaNode in
                    try mapMedia(mediaNode, sectionIndex: sectionIndex, mediaIndex: mediaIndex)
                }
            )
        }
    }

    /// Maps a clinical entry and its nested child entries.
    private func mapEntry(_ node: CCDAXMLNode, path: [String]) -> CCDAEntry {
        let directValue = node.first(.value)
        let identifiers = node.direct(.id).map(identifier)
        
        return CCDAEntry(
            id: CCDAStableID.entry(path: path, sourceId: identifiers.first?.stringValue),
            type: CCDAEntryType(elementName: node.name),
            templateIds: node.direct(.templateId).map(templateId),
            identifiers: identifiers,
            code: node.first(.code).map(codedValue),
            status: node.first(.statusCode)?.attribute(.code).map(CCDAEntryStatus.init(code:)),
            effectiveTime: effectiveTimeValue(from: node.first(.effectiveTime)),
            value: directValue.map(ccdaValue),
            textReference: node.first(.text)?.first(.reference)?.attribute(.value),
            children: node.direct(.entryRelationship).enumerated().flatMap { relationshipIndex, relationship in
                relationship.children.enumerated().map { childIndex, child in
                    mapEntry(
                        child,
                        path: path + ["r", String(relationshipIndex), String(childIndex)]
                    )
                }
            } + node.direct(.component).enumerated().flatMap { componentIndex, component in
                component.children.enumerated().map { childIndex, child in
                    mapEntry(
                        child,
                        path: path + ["c", String(componentIndex), String(childIndex)]
                    )
                }
            }
        )
    }

    /// Maps observationMedia into the current embedded media model.
    private func mapMedia(_ node: CCDAXMLNode, sectionIndex: Int, mediaIndex: Int) throws -> CCDAMedia? {
        guard let value = node.first(.value) else { return nil }
        let sourceId = node.attribute(.id) ?? node.first(.id)?.attribute(.root)
        let id = CCDAStableID.media(sectionIndex: sectionIndex, mediaIndex: mediaIndex, sourceId: sourceId)
        let mediaType = CCDAMediaType(mimeType: value.attribute(.mediaType))
        let representation = CCDAMediaRepresentation(rawValue: value.attribute(.representation))
        let base64Value = value.cleanText

        if case .cacheToDisk = configuration.mediaStoragePolicy,
           let cachedPayload = try cacheMediaIfPossible(id: id, mediaType: mediaType, base64Value: base64Value) {
            return CCDAMedia(
                id: id,
                mediaType: mediaType,
                representation: representation,
                payload: cachedPayload
            )
        }

        return CCDAMedia(
            id: id,
            mediaType: mediaType,
            representation: representation,
            payload: base64Value.isEmpty ? .unavailable : .inlineBase64(base64Value)
        )
    }

    /// Maps a templateId element.
    private func templateId(_ node: CCDAXMLNode) -> CCDATemplateId {
        CCDATemplateId(root: node.attribute(.root) ?? "", extensionValue: node.attribute(.extension))
    }

    /// Maps an id-like element.
    private func identifier(_ node: CCDAXMLNode) -> CCDAIdentifier {
        CCDAIdentifier(root: node.attribute(.root), extensionValue: node.attribute(.extension))
    }

    /// Maps standard code attributes into a coded value.
    private func codedValue(_ node: CCDAXMLNode) -> CCDACodedValue {
        CCDACodedValue(
            code: node.attribute(.code),
            codeSystem: node.attribute(.codeSystem),
            codeSystemName: node.attribute(.codeSystemName),
            displayName: node.attribute(.displayName)
        )
    }

    /// Maps value attributes from an entry value element.
    private func ccdaValue(_ node: CCDAXMLNode) -> CCDAValue {
        CCDAValue(
            type: node.attribute(.type) ?? node.attribute(.xsiType),
            code: node.attribute(.code),
            displayName: node.attribute(.displayName),
            value: node.attribute(.value),
            unit: node.attribute(.unit)
        )
    }

    /// Maps a C-CDA name element.
    private func humanName(_ node: CCDAXMLNode) -> CCDAHumanName {
        CCDAHumanName(
            prefix: node.first(.prefix)?.cleanText,
            given: node.direct(.given).map(\.cleanText),
            family: node.first(.family)?.cleanText
        )
    }

    /// Maps a C-CDA addr element.
    private func address(_ node: CCDAXMLNode) -> CCDAAddress {
        CCDAAddress(
            use: CCDAAddressUse(code: node.attribute(.use)),
            streetLines: node.direct(.streetAddressLine).map(\.cleanText),
            city: node.first(.city)?.cleanText,
            state: node.first(.state)?.cleanText,
            postalCode: node.first(.postalCode)?.cleanText,
            country: node.first(.country)?.cleanText
        )
    }

    /// Extracts effectiveTime using value, low, then high.
    private func effectiveTimeValue(from node: CCDAXMLNode?) -> CCDATimestamp? {
        guard let node else { return nil }
        return timestamp(
            node.attribute(.value)
            ?? node.first(.low)?.attribute(.value)
            ?? node.first(.high)?.attribute(.value)
        )
    }

    private func timestamp(_ rawValue: String?) -> CCDATimestamp? {
        guard let rawValue, !rawValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }

        return CCDATimestamp(rawValue: rawValue)
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

    private func cacheMediaIfPossible(
        id: String,
        mediaType: CCDAMediaType,
        base64Value: String
    ) throws -> CCDAMediaPayload? {
        guard let mediaCacheDirectory = configuration.mediaCacheDirectory,
              let data = Data(base64Encoded: base64Value.filter { !$0.isWhitespace }) else {
            return nil
        }

        do {
            let url = try CCDAMediaCache(directoryURL: mediaCacheDirectory)
                .store(data: data, id: id, mediaType: mediaType)
            return .cachedFile(url, byteCount: data.count)
        } catch {
            throw CCDAEngineError.mediaCacheWriteFailed(
                mediaCacheDirectory,
                error.localizedDescription
            )
        }
    }
}
