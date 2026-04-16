//
//  Schema.Timer.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension Schema {
    struct Timer: Sendable {
        let id: String
        let format: Schema.RangeTextFormat
        let actions: [Schema.Action]
        let horizontalAlign: HorizontalAlignment
    }
}

extension Schema.Timer: Schema.SimpleElement {
    @inlinable
    func buildElement(
        _ builder: Schema.ConfigurationBuilder,
        _ properties: VC.Element.Properties?
    ) -> VC.Element {
        try .timer(
            .init(
                id: id,
                format: builder.convertRangeTextFormat(format),
                actions: actions,
                horizontalAlign: horizontalAlign
            ),
            properties
        )
    }
}

extension Schema.Timer: DecodableWithConfiguration {
    enum CodingKeys: String, CodingKey {
        case id
        case format
        case actions = "action"
        case horizontalAlign = "align"
    }

    init(from decoder: Decoder, configuration: Schema.DecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)

        let formatItems =
            if let stringId = try? container.decode(String.self, forKey: .format) {
                [Schema.RangeTextFormat.Item(from: 0, stringId: stringId)]
            } else {
                try container.decode([Schema.RangeTextFormat.Item].self, forKey: .format)
            }

        format = try Schema.RangeTextFormat(
            items: formatItems,
            textAttributes: Schema.TextAttributes(from: decoder)
        )

        actions = try container.decodeIfPresentActions(forKey: .actions) ?? []

        horizontalAlign = try container.decodeIfPresent(Schema.HorizontalAlignment.self, forKey: .horizontalAlign) ?? .leading

        if configuration.isLegacy {
            configuration.collector.legacyTimers[id] = try Schema.decodeLegacySetTimer(id: id, from: decoder)
        }
    }
}

