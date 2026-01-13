//
//  Schema.AssetReference.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 09.01.2026.
//

import Foundation

extension Schema {
    typealias AssetReference = VC.AssetReference
}

extension Schema.AssetReference: Codable {
    enum CodingKeys: String, CodingKey {
        case value = "var"
    }

    package init(from decoder: Decoder) throws {
        if let assetId = try? decoder.singleValueContainer().decode(String.self) {
            self = .assetId(assetId)
            return
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        let value = try container.decode(String.self, forKey: .value)
        self = .value(path: value.split(separator: ".").map(String.init))
    }

    package func encode(to encoder: Encoder) throws {
        switch self {
        case .assetId(let value):
            var container = encoder.singleValueContainer()
            try container.encode(value)
        case .value(let path):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(path.joined(separator: "."), forKey: .value)
        }
    }
}
