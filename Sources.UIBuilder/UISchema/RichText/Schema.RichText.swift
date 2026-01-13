//
//  Schema.RichText.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 15.03.2024
//
//

import Foundation

extension Schema {
    struct RichText: Sendable, Hashable {
        let items: [RichText.Item]
    }
}

extension Schema.RichText {
    var isEmpty: Bool { items.isEmpty }

    var asString: String? {
        items.first.flatMap {
            if case let .text(value, attributes) = $0, attributes == nil { value } else { nil }
        }
    }
}

extension Schema.Localizer {
    func richText(
        stringId: String
    ) -> VC.RichText? {
        guard let item = localization?.strings?[stringId] else { return nil }
        return .init(
            items: item.value.items,
            fallback: item.fallback?.items
        )
    }
}

extension Schema.RichText: Codable {
    init(from decoder: Decoder) throws {
        items =
            if let value = try? Item(from: decoder) {
                [value]
            } else {
                try [Item](from: decoder)
            }
    }

    func encode(to encoder: any Encoder) throws {
        let items = items.filter {
            if case .unknown = $0 { false } else { true }
        }
        if items.count == 1 {
            try items[0].encode(to: encoder)
        } else {
            try items.encode(to: encoder)
        }
    }
}
