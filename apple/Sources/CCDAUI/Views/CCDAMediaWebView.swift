import Foundation
import SwiftUI
import WebKit
import CCDAEngine

#if os(iOS)
/// Web preview for PDF, plain text, and HTML media on iOS.
public struct CCDAMediaWebView: UIViewRepresentable {
    /// Media to preview.
    public let media: CCDAMedia

    /// Creates a web preview.
    public init(media: CCDAMedia) {
        self.media = media
    }

    public func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }

    public func updateUIView(_ webView: WKWebView, context: Context) {
        load(media, in: webView)
    }
}
#elseif os(macOS)
/// Web preview for PDF, plain text, and HTML media on macOS.
public struct CCDAMediaWebView: NSViewRepresentable {
    /// Media to preview.
    public let media: CCDAMedia

    /// Creates a web preview.
    public init(media: CCDAMedia) {
        self.media = media
    }

    public func makeNSView(context: Context) -> WKWebView {
        WKWebView()
    }

    public func updateNSView(_ webView: WKWebView, context: Context) {
        load(media, in: webView)
    }
}
#endif

private func load(_ media: CCDAMedia, in webView: WKWebView) {
    if case .cachedFile(let url, _) = media.payload {
        webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        return
    }

    do {
        let data = try media.loadData()
        if media.mediaType == .textHTML, let html = String(data: data, encoding: .utf8) {
            webView.loadHTMLString(html, baseURL: nil)
            return
        }

        webView.load(
            data,
            mimeType: media.mediaType.mimeType ?? "application/octet-stream",
            characterEncodingName: "utf-8",
            baseURL: URL(fileURLWithPath: NSTemporaryDirectory())
        )
    } catch {
        webView.loadHTMLString(
            "<html><body><p>Unable to load attachment.</p></body></html>",
            baseURL: nil
        )
    }
}
