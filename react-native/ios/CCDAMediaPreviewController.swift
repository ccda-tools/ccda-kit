import Foundation
import React
import UIKit
import WebKit

/// Native in-app preview using the same MIME handling as CCDAUI.
final class CCDAMediaPreviewController: UIViewController {
    private let data: Data
    private let mimeType: String

    private init(data: Data, mimeType: String, title: String) {
        self.data = data
        self.mimeType = mimeType
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    static func open(media: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        // Do not read attachment files on the UI thread.
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let types = [
                    "imagePNG": ("image/png", "Image"),
                    "imageJPEG": ("image/jpeg", "Image"),
                    "imageGIF": ("image/gif", "Image"),
                    "applicationPDF": ("application/pdf", "PDF"),
                    "textPlain": ("text/plain", "Text"),
                    "textHTML": ("text/html", "HTML")
                ]
                let kind = (media["mediaType"] as? NSDictionary)?["kind"] as? String ?? "unknown"
                guard let (mimeType, title) = types[kind] else {
                    throw failure("This attachment type cannot be previewed.")
                }
                let payload = media["payload"] as? NSDictionary
                let data: Data
                switch payload?["kind"] as? String {
                case "cachedFile":
                    guard let path = payload?["filePath"] as? String else {
                        throw failure("Attachment file is unavailable.")
                    }
                    data = try Data(contentsOf: URL(fileURLWithPath: path))
                case "inlineBase64":
                    guard let value = payload?["value"] as? String,
                          let decoded = Data(base64Encoded: value, options: .ignoreUnknownCharacters) else {
                        throw failure("Attachment data is invalid.")
                    }
                    data = decoded
                default:
                    throw failure("Attachment payload is unavailable.")
                }
                if mimeType.hasPrefix("image/"), UIImage(data: data) == nil {
                    throw failure("Unable to decode image attachment.")
                }
                DispatchQueue.main.async {
                    guard let presenter = RCTPresentedViewController(), presenter.viewIfLoaded?.window != nil else {
                        reject("CCDA_PREVIEW_FAILED", "No active screen is available to present the attachment.", nil)
                        return
                    }
                    let preview = CCDAMediaPreviewController(data: data, mimeType: mimeType, title: title)
                    let navigation = UINavigationController(rootViewController: preview)
                    presenter.present(navigation, animated: true) { resolve(nil) }
                }
            } catch {
                reject("CCDA_PREVIEW_FAILED", error.localizedDescription, error)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .close, primaryAction: UIAction { [weak self] _ in
            self?.dismiss(animated: true)
        })
        let content: UIView
        if mimeType.hasPrefix("image/"), let image = UIImage(data: data) {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.accessibilityLabel = "Image attachment"
            imageView.isAccessibilityElement = true
            content = imageView
        } else {
            let configuration = WKWebViewConfiguration()
            configuration.defaultWebpagePreferences.allowsContentJavaScript = false
            let webView = WKWebView(frame: .zero, configuration: configuration)
            webView.load(data, mimeType: mimeType, characterEncodingName: "utf-8", baseURL: URL(fileURLWithPath: NSTemporaryDirectory()))
            content = webView
        }
        content.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(content)
        NSLayoutConstraint.activate([
            content.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            content.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            content.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private static func failure(_ message: String) -> NSError {
        NSError(domain: "CCDAKit.MediaPreview", code: 1, userInfo: [NSLocalizedDescriptionKey: message])
    }
}
