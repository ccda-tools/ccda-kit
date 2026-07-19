import Foundation

public final class CCDAEngine {
    public init() {}

    public func parse(data: Data) throws -> CCDADocument {
        try parse(data: data, sourceDescription: nil)
    }

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

        return mapDocument(root)
    }

    private func mapDocument(_ root: XMLNode) -> CCDADocument {
        let header = CCDAHeader(
            realmCode: root.first("realmCode")?.attributes["code"],
            typeId: root.first("typeId").map(identifier),
            templateIds: root.direct("templateId").map(templateId),
            documentId: root.first("id").map(identifier) ?? CCDAIdentifier(root: nil, extensionValue: nil),
            code: root.first("code").map(codedValue),
            title: root.first("title")?.cleanText,
            effectiveTime: root.first("effectiveTime")?.attributes["value"],
            confidentialityCode: root.first("confidentialityCode").map(codedValue),
            languageCode: root.first("languageCode")?.attributes["code"]
        )

        return CCDADocument(
            header: header,
            patient: mapPatient(root),
            sections: mapSections(root)
        )
    }

    private func mapPatient(_ root: XMLNode) -> CCDAPatient? {
        guard let patientRole = root.first("recordTarget")?.first("patientRole") else {
            return nil
        }

        let patient = patientRole.first("patient")

        return CCDAPatient(
            ids: patientRole.direct("id").map(identifier),
            name: patient?.first("name").map(humanName),
            gender: patient?.first("administrativeGenderCode").map(codedValue),
            birthTime: patient?.first("birthTime")?.attributes["value"],
            maritalStatus: patient?.first("maritalStatusCode").map(codedValue),
            race: patient?.first("raceCode").map(codedValue),
            ethnicity: patient?.first("ethnicGroupCode").map(codedValue),
            addresses: patientRole.direct("addr").map(address),
            telecoms: patientRole.direct("telecom").compactMap { $0.attributes["value"] }
        )
    }

    private func mapSections(_ root: XMLNode) -> [CCDASection] {
        guard let structuredBody = root.first("component")?.first("structuredBody") else {
            return []
        }

        return structuredBody.direct("component").compactMap { component in
            guard let section = component.first("section") else { return nil }
            return CCDASection(
                templateIds: section.direct("templateId").map(templateId),
                code: section.first("code").map(codedValue),
                title: section.first("title")?.cleanText,
                narrativeText: section.first("text")?.cleanText ?? "",
                entries: section.direct("entry").flatMap { entry in
                    entry.children
                        .filter { $0.name != "observationMedia" }
                        .map(mapEntry)
                },
                media: section.direct("entry").flatMap { entry in
                    entry.children
                        .filter { $0.name == "observationMedia" }
                        .compactMap(mapMedia)
                }
            )
        }
    }

    private func mapEntry(_ node: XMLNode) -> CCDAEntry {
        let directValue = node.first("value")

        return CCDAEntry(
            type: node.name,
            templateIds: node.direct("templateId").map(templateId),
            identifiers: node.direct("id").map(identifier),
            code: node.first("code").map(codedValue),
            status: node.first("statusCode")?.attributes["code"],
            effectiveTime: effectiveTimeValue(from: node.first("effectiveTime")),
            value: directValue.map(ccdaValue),
            textReference: node.first("text")?.first("reference")?.attributes["value"],
            children: node.direct("entryRelationship").flatMap { relationship in
                relationship.children.map(mapEntry)
            } + node.direct("component").flatMap { component in
                component.children.map(mapEntry)
            }
        )
    }

    private func mapMedia(_ node: XMLNode) -> CCDAMedia? {
        guard let value = node.first("value") else { return nil }
        return CCDAMedia(
            id: node.attributes["ID"] ?? node.first("id")?.attributes["root"] ?? UUID().uuidString,
            mediaType: value.attributes["mediaType"],
            representation: value.attributes["representation"],
            base64Value: value.cleanText
        )
    }

    private func templateId(_ node: XMLNode) -> CCDATemplateId {
        CCDATemplateId(root: node.attributes["root"] ?? "", extensionValue: node.attributes["extension"])
    }

    private func identifier(_ node: XMLNode) -> CCDAIdentifier {
        CCDAIdentifier(root: node.attributes["root"], extensionValue: node.attributes["extension"])
    }

    private func codedValue(_ node: XMLNode) -> CCDACodedValue {
        CCDACodedValue(
            code: node.attributes["code"],
            codeSystem: node.attributes["codeSystem"],
            codeSystemName: node.attributes["codeSystemName"],
            displayName: node.attributes["displayName"]
        )
    }

    private func ccdaValue(_ node: XMLNode) -> CCDAValue {
        CCDAValue(
            type: node.attributes["type"] ?? node.attributes["xsi:type"],
            code: node.attributes["code"],
            displayName: node.attributes["displayName"],
            value: node.attributes["value"],
            unit: node.attributes["unit"]
        )
    }

    private func humanName(_ node: XMLNode) -> CCDAHumanName {
        CCDAHumanName(
            prefix: node.first("prefix")?.cleanText,
            given: node.direct("given").map(\.cleanText),
            family: node.first("family")?.cleanText
        )
    }

    private func address(_ node: XMLNode) -> CCDAAddress {
        CCDAAddress(
            use: node.attributes["use"],
            streetLines: node.direct("streetAddressLine").map(\.cleanText),
            city: node.first("city")?.cleanText,
            state: node.first("state")?.cleanText,
            postalCode: node.first("postalCode")?.cleanText,
            country: node.first("country")?.cleanText
        )
    }

    private func effectiveTimeValue(from node: XMLNode?) -> String? {
        guard let node else { return nil }
        return node.attributes["value"]
            ?? node.first("low")?.attributes["value"]
            ?? node.first("high")?.attributes["value"]
    }

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

    private func positive(_ value: Int) -> Int? {
        value > 0 ? value : nil
    }
}
