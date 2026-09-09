//
//  Schema.DataAsset.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 31.08.2026.
//

import Foundation

extension Schema {
    typealias DataAsset = VC.DataAsset
}

extension Schema.DataAsset {
    static let assetType = "data"
}

extension Schema.DataAsset: Decodable {
    private enum CodingKeys: String, CodingKey {
        case format
        case value
        case url
        case customId = "custom_id"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let format = try container.decode(String.self, forKey: .format)
        guard !format.isEmpty else {
            throw DecodingError.dataCorruptedError(
                forKey: .format,
                in: container,
                debugDescription: "must not be empty"
            )
        }

        let hasValue = container.contains(.value)
        let hasURL = container.contains(.url)
        guard hasValue || hasURL else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: container.codingPath,
                    debugDescription: "must contain at least one of value or url"
                )
            )
        }

        var value: Data?
        if hasValue {
            let base64EncodedData = try container.decode(String.self, forKey: .value)
            guard let data = Data(base64Encoded: base64EncodedData) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .value,
                    in: container,
                    debugDescription: "must be base64 encoded data"
                )
            }
            value = data
        }

        var url: URL?
        if hasURL {
            let string = try container.decode(String.self, forKey: .url)
            guard !string.isEmpty, let value = URL(string: string) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .url,
                    in: container,
                    debugDescription: "must be a non-empty URL"
                )
            }
            url = value
        }

        let customId = try container.decodeIfPresent(String.self, forKey: .customId)
        self.init(
            url: url,
            value: value,
            customId: customId,
            format: format
        )
    }
}
