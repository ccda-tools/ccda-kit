import Foundation

/// Lightweight XML node used by the parser mapper.
final class CCDAXMLNode {
    /// Element name after namespace processing.
    let name: String
    /// Element attributes keyed by attribute name.
    let attributes: [String: String]
    /// Text directly found inside this node.
    var text = ""
    /// Child elements in document order.
    var children: [CCDAXMLNode] = []
    
    /// Creates a node from parser element data.
    init(name: String, attributes: [String: String]) {
        self.name = name
        self.attributes = attributes
    }
    
    /// Whitespace-normalized text including child text.
    var cleanText: String {
        allText
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Raw text from this node and all descendants.
    private var allText: String {
        ([text] + children.map(\.allText)).joined(separator: " ")
    }
    
    /// Returns direct children matching a raw element name.
    func direct(_ name: String) -> [CCDAXMLNode] {
        children.filter { $0.name == name }
    }

    /// Returns direct children matching a known C-CDA element.
    func direct(_ element: CCDAXMLElement) -> [CCDAXMLNode] {
        direct(element.rawValue)
    }
    
    /// Returns the first descendant matching a raw element name.
    func first(_ name: String) -> CCDAXMLNode? {
        if let child = children.first(where: { $0.name == name }) {
            return child
        }
        
        for child in children {
            if let match = child.first(name) {
                return match
            }
        }
        
        return nil
    }

    /// Returns the first descendant matching a known C-CDA element.
    func first(_ element: CCDAXMLElement) -> CCDAXMLNode? {
        first(element.rawValue)
    }

    /// Returns an attribute value for a known C-CDA attribute.
    func attribute(_ attribute: CCDAXMLAttribute) -> String? {
        attributes[attribute.rawValue]
    }

    /// Checks whether this node has the given C-CDA element name.
    func isNamed(_ element: CCDAXMLElement) -> Bool {
        name == element.rawValue
    }
}
