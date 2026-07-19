import Foundation

final class XMLNode {
    let name: String
    let attributes: [String: String]
    var text = ""
    var children: [XMLNode] = []

    init(name: String, attributes: [String: String]) {
        self.name = name
        self.attributes = attributes
    }

    var cleanText: String {
        allText
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var allText: String {
        ([text] + children.map(\.allText)).joined(separator: " ")
    }

    func direct(_ name: String) -> [XMLNode] {
        children.filter { $0.name == name }
    }

    func first(_ name: String) -> XMLNode? {
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
}
