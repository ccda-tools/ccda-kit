import Foundation

/// XMLParser delegate that builds a lightweight CCDAXMLNode tree.
final class XMLDOMBuilder: NSObject, XMLParserDelegate {
    /// Root node of the parsed XML document.
    private(set) var root: CCDAXMLNode?
    /// Stack of open elements while parsing.
    private var stack: [CCDAXMLNode] = []

    /// Appends a new node for each opening XML element.
    func parser(_ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes: [String: String] = [:]) {
        let node = CCDAXMLNode(name: elementName, attributes: attributes)

        if let parent = stack.last {
            parent.children.append(node)
        } else {
            root = node
        }

        stack.append(node)
    }

    /// Appends character content to the current node.
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        stack.last?.text += string
    }

    /// Closes the current node when an ending XML element is reached.
    func parser(_ parser: XMLParser,
                didEndElement elementName: String,
                namespaceURI: String?,
                qualifiedName: String?) {
        _ = stack.popLast()
    }
}
