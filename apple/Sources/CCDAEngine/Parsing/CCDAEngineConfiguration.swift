import Foundation

/// Parser configuration for memory and media behavior.
public struct CCDAEngineConfiguration: Sendable {
    /// Default parser behavior.
    public static let `default` = CCDAEngineConfiguration(
        mediaCacheDirectory: FileManager.default.temporaryDirectory
            .appendingPathComponent("ccda-kit-media-cache")
    )

    /// Controls how embedded media payloads are stored.
    public let mediaStoragePolicy: CCDAMediaStoragePolicy
    /// Directory used when media is written to disk.
    public let mediaCacheDirectory: URL?

    /// Creates a parser configuration.
    public init(
        mediaStoragePolicy: CCDAMediaStoragePolicy = .cacheToDisk,
        mediaCacheDirectory: URL? = FileManager.default.temporaryDirectory
            .appendingPathComponent("ccda-kit-media-cache")
    ) {
        self.mediaStoragePolicy = mediaStoragePolicy
        self.mediaCacheDirectory = mediaCacheDirectory
    }
}

/// Storage policy for embedded C-CDA media.
public enum CCDAMediaStoragePolicy: Sendable {
    /// Keep base64 media payloads in the parsed model.
    case inline
    /// Decode valid base64 media and write it to disk.
    case cacheToDisk
}
