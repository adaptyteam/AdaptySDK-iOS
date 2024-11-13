//
//  Request.SetFallbackPaywalls.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 08.11.2024.
//

import Adapty
import Foundation

extension Request {
    struct SetFallbackPaywalls: AdaptyPluginRequest {
        static let method = "set_fallback_paywalls"

        let fileURL: URL

        enum CodingKeys: String, CodingKey {
            case fileURL = "file_url"
        }

        init(from jsonDictionary: AdaptyJsonDictionary) throws {
            try self.init(
                fileURL: jsonDictionary.value(forKey: CodingKeys.fileURL)
            )
        }

        init(fileURL: KeyValue) throws {
            if let url = try? fileURL.cast(URL.self) {
                self.fileURL = url
                return
            }

            if let url = try URL(string: fileURL.cast(String.self)) {
                self.fileURL = url
                return
            }

            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.fileURL], debugDescription: "Is not URL"))
        }

        func execute() async throws -> AdaptyJsonData {
            try await Adapty.setFallbackPaywalls(fileURL: fileURL)
            return .success()
        }
    }
}

public extension AdaptyPlugin {
    @objc static func setFallbackPaywalls(
        fileURL: String,
        _ completion: @escaping AdaptyJsonDataCompletion
    ) {
        typealias CodingKeys = Request.SetFallbackPaywalls.CodingKeys
        execute(with: completion) { try Request.SetFallbackPaywalls(
            fileURL: .init(key: CodingKeys.fileURL, value: fileURL)
        ) }
    }
}
