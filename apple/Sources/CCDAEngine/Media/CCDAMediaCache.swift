import Foundation

/// Disk cache for extracted C-CDA media payloads.
struct CCDAMediaCache: Sendable {
    /// Directory where decoded media files are stored.
    let directoryURL: URL

    /// Stores decoded media data and returns the file URL.
    func store(data: Data, id: String, mediaType: CCDAMediaType) throws -> URL {
        try FileManager.default.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true
        )

        let fileURL = directoryURL
            .appendingPathComponent(safeFileName(for: id))
            .appendingPathExtension(fileExtension(for: mediaType))

        try data.write(to: fileURL, options: [.atomic])
        return fileURL
    }

    private func safeFileName(for id: String) -> String {
        let safeCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_"))
        let scalars = id.unicodeScalars.map { scalar in
            safeCharacters.contains(scalar) ? Character(scalar) : "-"
        }
        let fileName = String(scalars).trimmingCharacters(in: CharacterSet(charactersIn: "-"))
        return fileName.isEmpty ? UUID().uuidString : fileName
    }

    private func fileExtension(for mediaType: CCDAMediaType) -> String {
        switch mediaType {
        case .imageJPEG:
            return "jpg"
        case .imagePNG:
            return "png"
        case .imageGIF:
            return "gif"
        case .applicationPDF:
            return "pdf"
        case .textPlain:
            return "txt"
        case .textHTML:
            return "html"
        case .unsupported, .unknown:
            return "bin"
        }
    }
}
