//
//  Schema.RangeTextFormat.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 15.03.2026.
//

import Foundation

extension Schema {
    struct RangeTextFormat: Sendable {
        let items: [Item]
        let textAttributes: Schema.TextAttributes?
    }
}

extension Schema.ConfigurationBuilder {
    @inlinable
    func convertRangeTextFormat(_ from: Schema.RangeTextFormat) -> VC.RangeTextFormat {
        .init(
            items: from.items.compactMap {
                guard let value = strings[$0.stringId] else { return nil }

                return .init(
                    from: $0.from,
                    value: value
                )
            },
            textAttributes: from.textAttributes
        )
    }
}

extension KeyedDecodingContainer {
    func decodeRangeTextFormat(textAttributes: Schema.TextAttributes, forKey key: Key) throws -> Schema.RangeTextFormat {
        let formatItems =
        if let stringId = try? decode(String.self, forKey: key) {
            [Schema.RangeTextFormat.Item(from: 0, stringId: stringId)]
        } else {
            try decode([Schema.RangeTextFormat.Item].self, forKey: key)
        }

        guard !formatItems.isEmpty else {
            throw DecodingError
                .dataCorruptedError(forKey: key, in: self, debugDescription: "Must be at least one format item")
        }

        return .init(
            items: formatItems,
            textAttributes: textAttributes
        )
    }


}
