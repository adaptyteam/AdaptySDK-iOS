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
        static let method = Method.setFallbackPaywalls

        let fileURL: URL

        init(from jsonDictionary: AdaptyJsonDictionary) throws {
            try self.init(
                fileURL: jsonDictionary.value(forKey: CodingKeys.fileURL)
            )
        }

        init(fileURL: KeyValue) throws {
            self.fileURL = try fileURL.decode(URL.self)
        }

        func execute() async throws -> AdaptyJsonData {
            try await Adapty.setFallbackPaywalls(fileURL: fileURL)
            return .success()
        }
    }
}

private enum CodingKeys: String, CodingKey {
    case fileURL = "file_url"
}

public extension AdaptyPlugin {
    @objc static func setFallbackPaywalls(
        fileURL: String,
        _ completion: @escaping AdaptyJsonDataCompletion
    ) {
        withCompletion(completion) {
            await Request.SetFallbackPaywalls.execute {
                try Request.SetFallbackPaywalls(
                    fileURL: .init(key: CodingKeys.fileURL, value: fileURL)
                )
            }
        }
    }
}
