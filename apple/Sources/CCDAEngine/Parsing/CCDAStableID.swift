import Foundation

enum CCDAStableID {
    static func section(index: Int, code: String?, title: String?) -> String {
        encoded(prefix: "s", parts: [String(index), code ?? "", title ?? ""])
    }

    static func entry(path: [String], sourceId: String?) -> String {
        encoded(prefix: "e", parts: path + [sourceId ?? ""])
    }

    static func media(sectionIndex: Int, mediaIndex: Int, sourceId: String?) -> String {
        encoded(prefix: "m", parts: [String(sectionIndex), String(mediaIndex), sourceId ?? ""])
    }

    private static func encoded(prefix: String, parts: [String]) -> String {
        let raw = parts.joined(separator: "|")
        let encoded = Data(raw.utf8)
            .base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")

        return "\(prefix):\(encoded)"
    }
}
