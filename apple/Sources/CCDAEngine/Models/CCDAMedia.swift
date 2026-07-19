import Foundation

public struct CCDAMedia: Identifiable {
    public let id: String
    public let mediaType: String?
    public let representation: String?
    public let base64Value: String

    public var data: Data? {
        Data(base64Encoded: base64Value.filter { !$0.isWhitespace })
    }

    public var isImage: Bool {
        mediaType?.hasPrefix("image/") == true
    }
}
