//
//  Schema.RangeTextFormat.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 15.03.2026.
//

import Foundation

extension Schema {
    struct RangeTextFormat: Sendable, Hashable {
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
