//
//  Schema.AssetsCollection.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 08.02.2026.
//
import Foundation

extension Schema {
    struct AssetsCollection: Codable {
        let value: [AssetIdentifier: Asset]

        init(value: [AssetIdentifier: Asset]) {
            self.value = value
        }

        init(from decoder: Decoder) throws {
            let array = try decoder.singleValueContainer().decode([Item].self)
            value = try [AssetIdentifier: Asset](array.map { ($0.id, $0.value) }, uniquingKeysWith: { _, _ in
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Duplicate key"))
            })
        }

        func encode(to encoder: any Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(value.map(Item.init))
        }

        private struct Item: Codable {
            let id: AssetIdentifier
            let value: Asset

            init(id: AssetIdentifier, value: Asset) {
                self.id = id
                self.value = value
            }

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: Asset.CodingKeys.self)
                id = try container.decode(String.self, forKey: .id)
                value = try Asset(from: decoder)
            }

            func encode(to encoder: any Encoder) throws {
                try value.encode(to: encoder)
                var container = encoder.container(keyedBy: Asset.CodingKeys.self)
                try container.encode(id, forKey: .id)
            }
        }
    }
}
