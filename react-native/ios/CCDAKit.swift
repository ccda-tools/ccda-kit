import CCDAEngine
import Foundation
import React

@objc(CCDAKit)
final class CCDAKit: NSObject {
    @objc(openMedia:resolver:rejecter:)
    func openMedia(
        _ media: NSDictionary,
        resolver resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        CCDAMediaPreviewController.open(media: media, resolve: resolve, reject: reject)
    }

    @objc
    static func requiresMainQueueSetup() -> Bool {
        false
    }

    @objc(parseXml:options:resolver:rejecter:)
    func parseXml(
        _ xml: String,
        options: NSDictionary?,
        resolver resolve: RCTPromiseResolveBlock,
        rejecter reject: RCTPromiseRejectBlock
    ) {
        do {
            guard let data = xml.data(using: .utf8) else {
                reject("CCDA_INVALID_INPUT", "XML input could not be encoded as UTF-8.", nil)
                return
            }

            let document = try engine(options: options).parse(data: data)
            resolve(document.reactNativeValue)
        } catch {
            self.reject(error, reject: reject)
        }
    }

    @objc(parseFile:options:resolver:rejecter:)
    func parseFile(
        _ path: String,
        options: NSDictionary?,
        resolver resolve: RCTPromiseResolveBlock,
        rejecter reject: RCTPromiseRejectBlock
    ) {
        do {
            let url = fileURL(from: path)
            let document = try engine(options: options).parse(url: url)
            resolve(document.reactNativeValue)
        } catch {
            self.reject(error, reject: reject)
        }
    }

    private func engine(options: NSDictionary?) -> CCDAEngine {
        let storagePolicy: CCDAMediaStoragePolicy
        if options?["mediaStoragePolicy"] as? String == "inline" {
            storagePolicy = .inline
        } else {
            storagePolicy = .cacheToDisk
        }

        let cacheDirectory = (options?["mediaCacheDirectory"] as? String).map(URL.init(fileURLWithPath:))
            ?? FileManager.default.temporaryDirectory.appendingPathComponent("ccda-kit-media-cache")

        return CCDAEngine(
            configuration: CCDAEngineConfiguration(
                mediaStoragePolicy: storagePolicy,
                mediaCacheDirectory: cacheDirectory
            )
        )
    }

    private func fileURL(from path: String) -> URL {
        if path.hasPrefix("file://"), let url = URL(string: path) {
            return url
        }

        return URL(fileURLWithPath: path)
    }

    private func reject(_ error: Error, reject: RCTPromiseRejectBlock) {
        if let engineError = error as? CCDAEngineError, case .invalidXML = engineError {
            reject("CCDA_INVALID_XML", error.localizedDescription, error)
        } else {
            reject("CCDA_PARSE_FAILED", error.localizedDescription, error)
        }
    }
}

private extension CCDADocument {
    var reactNativeValue: [String: Any] {
        bridgeMap([
            "id": id,
            "header": header.reactNativeValue,
            "patient": patient?.reactNativeValue,
            "sections": sections.map(\.reactNativeValue)
        ])
    }
}

private extension CCDAHeader {
    var reactNativeValue: [String: Any] {
        bridgeMap([
            "realmCode": realmCode,
            "typeId": typeId?.reactNativeValue,
            "templateIds": templateIds.map(\.reactNativeValue),
            "documentId": documentId.reactNativeValue,
            "code": code?.reactNativeValue,
            "title": title,
            "effectiveTime": effectiveTime?.reactNativeValue,
            "confidentialityCode": confidentialityCode?.reactNativeValue,
            "languageCode": languageCode
        ])
    }
}

private extension CCDAPatient {
    var reactNativeValue: [String: Any] {
        bridgeMap([
            "ids": ids.map(\.reactNativeValue),
            "name": name?.reactNativeValue,
            "gender": gender?.reactNativeValue,
            "birthTime": birthTime?.reactNativeValue,
            "maritalStatus": maritalStatus?.reactNativeValue,
            "race": race?.reactNativeValue,
            "ethnicity": ethnicity?.reactNativeValue,
            "addresses": addresses.map(\.reactNativeValue),
            "telecoms": telecoms
        ])
    }
}

private extension CCDASection {
    var reactNativeValue: [String: Any] {
        bridgeMap([
            "id": id,
            "templateIds": templateIds.map(\.reactNativeValue),
            "code": code?.reactNativeValue,
            "kind": kind.reactNativeValue,
            "title": title,
            "narrativeText": narrativeText,
            "entries": entries.map(\.reactNativeValue),
            "media": media.map(\.reactNativeValue)
        ])
    }
}

private extension CCDAEntry {
    var reactNativeValue: [String: Any] {
        bridgeMap([
            "id": id,
            "type": type.rawValue,
            "templateIds": templateIds.map(\.reactNativeValue),
            "identifiers": identifiers.map(\.reactNativeValue),
            "code": code?.reactNativeValue,
            "status": status?.rawValue,
            "effectiveTime": effectiveTime?.reactNativeValue,
            "value": value?.reactNativeValue,
            "textReference": textReference,
            "children": children.map(\.reactNativeValue)
        ])
    }
}

private extension CCDAMedia {
    var reactNativeValue: [String: Any] {
        bridgeMap([
            "id": id,
            "mediaType": mediaType.reactNativeValue,
            "representation": representation.reactNativeValue,
            "payload": payload.reactNativeValue,
            "isImage": isImage,
            "isCached": isCached
        ])
    }
}

private extension CCDAMediaType {
    var reactNativeValue: [String: Any] {
        bridgeMap([
            "kind": reactNativeKind,
            "mimeType": mimeType
        ])
    }

    var reactNativeKind: String {
        switch self {
        case .imagePNG:
            return "imagePNG"
        case .imageJPEG:
            return "imageJPEG"
        case .imageGIF:
            return "imageGIF"
        case .applicationPDF:
            return "applicationPDF"
        case .textPlain:
            return "textPlain"
        case .textHTML:
            return "textHTML"
        case .unsupported:
            return "unsupported"
        case .unknown:
            return "unknown"
        }
    }
}

private extension CCDAMediaRepresentation {
    var reactNativeValue: [String: Any] {
        bridgeMap([
            "kind": reactNativeKind,
            "rawValue": rawValue
        ])
    }

    var reactNativeKind: String {
        switch self {
        case .base64:
            return "base64"
        case .text:
            return "text"
        case .unsupported:
            return "unsupported"
        case .unknown:
            return "unknown"
        }
    }
}

private extension CCDAMediaPayload {
    var reactNativeValue: [String: Any] {
        switch self {
        case .cachedFile(let url, let byteCount):
            return bridgeMap([
                "kind": "cachedFile",
                "filePath": url.path,
                "fileUri": url.absoluteString,
                "byteCount": byteCount
            ])
        case .inlineBase64(let value):
            return bridgeMap([
                "kind": "inlineBase64",
                "value": value
            ])
        case .unavailable:
            return bridgeMap(["kind": "unavailable"])
        }
    }
}

private extension CCDAIdentifier {
    var reactNativeValue: [String: Any] {
        bridgeMap([
            "root": root,
            "extensionValue": extensionValue,
            "stringValue": stringValue
        ])
    }
}

private extension CCDATemplateId {
    var reactNativeValue: [String: Any] {
        bridgeMap([
            "root": root,
            "extensionValue": extensionValue
        ])
    }
}

private extension CCDACodedValue {
    var reactNativeValue: [String: Any] {
        bridgeMap([
            "code": code,
            "codeSystem": codeSystem,
            "codeSystemName": codeSystemName,
            "displayName": displayName
        ])
    }
}

private extension CCDATimestamp {
    var reactNativeValue: [String: Any] {
        bridgeMap([
            "rawValue": rawValue,
            "year": year,
            "month": month,
            "day": day,
            "hour": hour,
            "minute": minute,
            "second": second,
            "fractionalSecond": fractionalSecond,
            "timeZoneOffset": timeZoneOffset,
            "hasTime": hasTime
        ])
    }
}

private extension CCDAValue {
    var reactNativeValue: [String: Any] {
        bridgeMap([
            "type": type,
            "code": code,
            "displayName": displayName,
            "value": value,
            "unit": unit
        ])
    }
}

private extension CCDAHumanName {
    var reactNativeValue: [String: Any] {
        bridgeMap([
            "prefix": prefix,
            "given": given,
            "family": family
        ])
    }
}

private extension CCDAAddress {
    var reactNativeValue: [String: Any] {
        bridgeMap([
            "use": use.code ?? "unknown",
            "streetLines": streetLines,
            "city": city,
            "state": state,
            "postalCode": postalCode,
            "country": country
        ])
    }
}

private extension CCDASectionKind {
    var reactNativeValue: String {
        switch self {
        case .allergies:
            return "allergies"
        case .assessment:
            return "assessment"
        case .planOfCare:
            return "planOfCare"
        case .encounters:
            return "encounters"
        case .functionalStatus:
            return "functionalStatus"
        case .immunizations:
            return "immunizations"
        case .medicalEquipment:
            return "medicalEquipment"
        case .medications:
            return "medications"
        case .payers:
            return "payers"
        case .problems:
            return "problems"
        case .procedures:
            return "procedures"
        case .reasonForReferral:
            return "reasonForReferral"
        case .results:
            return "results"
        case .socialHistory:
            return "socialHistory"
        case .vitalSigns:
            return "vitalSigns"
        case .unknown:
            return "unknown"
        }
    }
}

private func bridgeMap(_ values: [String: Any?]) -> [String: Any] {
    values.reduce(into: [String: Any]()) { result, pair in
        result[pair.key] = pair.value ?? NSNull()
    }
}
