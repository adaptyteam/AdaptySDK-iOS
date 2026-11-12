//
//  Schema.DeckItem.Length.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 21.08.2026.
//

import Foundation

extension Schema.DeckItem {
    typealias Length = VC.DeckItem.Length
}

extension Schema.DeckItem.Length: Decodable {
    enum CodingKeys: String, CodingKey {
        case parent
    }

    init(from decoder: Decoder) throws {
        let singleValueContainer = try decoder.singleValueContainer()
        if let value = try? singleValueContainer.decode(Schema.Unit.self) {
            guard !value.isNegative else {
                throw DecodingError.dataCorruptedError(
                    in: singleValueContainer,
                    debugDescription: "DeckItem fixed length must be nonnegative"
                )
            }

            self = .fixed(value)
            return
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        let value = try container.decode(Double.self, forKey: .parent)

        guard value >= 0 else {
            throw DecodingError.dataCorruptedError(
                forKey: .parent,
                in: container,
                debugDescription: "DeckItem parent length must be nonnegative"
            )
        }

        self = .parent(value)
    }
}
