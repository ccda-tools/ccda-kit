import Foundation

public struct CCDADocument: Identifiable {
    public var id: String { header.documentId.display }
    public let header: CCDAHeader
    public let patient: CCDAPatient?
    public let sections: [CCDASection]
}
