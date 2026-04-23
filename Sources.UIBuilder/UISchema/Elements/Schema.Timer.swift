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
        let maxRows: Int?
        let overflowMode: Set<Schema.Text.OverflowMode>
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
                horizontalAlign: horizontalAlign,
                maxRows: maxRows,
                overflowMode: overflowMode
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
        case maxRows = "max_rows"
        case overflowMode = "on_overflow"
    }

    init(from decoder: Decoder, configuration: Schema.DecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(String.self, forKey: .id)

        let (maxRows, overflowMode): (Int?, Set<Schema.Text.OverflowMode>) =
            if configuration.isLegacy {
                (1, [.scale])
            } else {
                try (
                    container.decodeIfPresent(Int.self, forKey: .maxRows),
                    container.decodeIfPresentTextOverflowMode(forKey: .overflowMode)
                )
            }

        try self.init(
            id: id,
            format: container.decodeRangeTextFormat(
                textAttributes: .init(from: decoder),
                forKey: .format
            ),
            actions: container.decodeIfPresentActions(forKey: .actions) ?? [],
            horizontalAlign: container.decodeIfPresent(Schema.HorizontalAlignment.self, forKey: .horizontalAlign) ?? .leading,
            maxRows: maxRows,
            overflowMode: overflowMode
        )

        if configuration.isLegacy {
            configuration.collector.legacyTimers[id] = try Schema.decodeLegacySetTimer(id: id, from: decoder)
        }
    }
}

