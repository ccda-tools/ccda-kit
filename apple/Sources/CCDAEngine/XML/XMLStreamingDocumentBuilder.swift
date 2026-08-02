import Foundation

/// XMLParser delegate that captures document metadata and maps section subtrees as they close.
final class XMLStreamingDocumentBuilder: NSObject, XMLParserDelegate {
    /// Root node containing document-level metadata outside structuredBody.
    private(set) var root: CCDAXMLNode?
    /// Sections mapped in document order.
    private(set) var sections: [CCDASection] = []
    /// First error thrown by a section mapper.
    private(set) var mappingError: Error?

    private var path: [String] = []
    private var headerStack: [CCDAXMLNode] = []
    private var sectionStack: [CCDAXMLNode] = []
    private var skippedBodyDepth = 0
    private let sectionMapper: (CCDAXMLNode, Int) throws -> CCDASection

    /// Creates a streaming builder with a section mapper.
    init(sectionMapper: @escaping (CCDAXMLNode, Int) throws -> CCDASection) {
        self.sectionMapper = sectionMapper
    }

    /// Routes opening elements into either document metadata or the active section subtree.
    func parser(_ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes: [String: String] = [:]) {
        let node = CCDAXMLNode(name: elementName, attributes: attributes)

        if !sectionStack.isEmpty {
            sectionStack.last?.children.append(node)
            sectionStack.append(node)
        } else if isStructuredBodySectionStart(elementName) {
            sectionStack.append(node)
        } else if skippedBodyDepth > 0 {
            skippedBodyDepth += 1
        } else if isRootBodyComponent(elementName) {
            skippedBodyDepth = 1
        } else if let parent = headerStack.last {
            parent.children.append(node)
            headerStack.append(node)
        } else {
            root = node
            headerStack.append(node)
        }

        path.append(elementName)
    }

    /// Appends character content to the active capture target.
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if !sectionStack.isEmpty {
            sectionStack.last?.text += string
        } else if skippedBodyDepth == 0 {
            headerStack.last?.text += string
        }
    }

    /// Closes elements and maps completed section subtrees immediately.
    func parser(_ parser: XMLParser,
                didEndElement elementName: String,
                namespaceURI: String?,
                qualifiedName: String?) {
        if !sectionStack.isEmpty {
            closeSectionElement(elementName, parser: parser)
        } else if skippedBodyDepth > 0 {
            skippedBodyDepth -= 1
        } else {
            _ = headerStack.popLast()
        }

        _ = path.popLast()
    }

    private func closeSectionElement(_ elementName: String, parser: XMLParser) {
        guard elementName == CCDAXMLElement.section.rawValue, sectionStack.count == 1 else {
            _ = sectionStack.popLast()
            return
        }

        guard let sectionNode = sectionStack.popLast() else { return }

        do {
            let section = try sectionMapper(sectionNode, sections.count)
            sections.append(section)
        } catch {
            mappingError = error
            parser.abortParsing()
        }
    }

    private func isStructuredBodySectionStart(_ elementName: String) -> Bool {
        elementName == CCDAXMLElement.section.rawValue
            && path.last == CCDAXMLElement.component.rawValue
            && path.dropLast().last == CCDAXMLElement.structuredBody.rawValue
    }

    private func isRootBodyComponent(_ elementName: String) -> Bool {
        elementName == CCDAXMLElement.component.rawValue
            && path.count == 1
            && path.first == "ClinicalDocument"
    }
}
