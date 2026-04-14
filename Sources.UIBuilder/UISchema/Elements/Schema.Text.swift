//
//  Schema.Text.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension Schema {
    typealias Text = VC.Text
}

extension Schema.Text: Schema.SimpleElement {
    @inlinable
    func buildElement(
        _: Schema.ConfigurationBuilder,
        _ properties: VC.Element.Properties?
    ) -> VC.Element {
        try .text(self, properties)
    }
}

extension Schema.Text: Decodable {
    enum CodingKeys: String, CodingKey {
        case stringId = "string_id"
        case horizontalAlign = "align"
        case maxRows = "max_rows"
        case overflowMode = "on_overflow"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let overflowMode =
            if let value = try? container.decode(OverflowMode.self, forKey: .overflowMode) {
                Set([value])
            } else {
                try Set(container.decodeIfPresent([OverflowMode].self, forKey: .overflowMode) ?? [])
            }

        let textAttributes = try Schema.TextAttributes(from: decoder)

        try self.init(
            value: container.decode(Schema.StringReference.self, forKey: .stringId),
            horizontalAlign: container.decodeIfPresent(Schema.HorizontalAlignment.self, forKey: .horizontalAlign) ?? .leading,
            maxRows: container.decodeIfPresent(Int.self, forKey: .maxRows),
            overflowMode: overflowMode,
            defaultTextAttributes: textAttributes.nonEmptyOrNil
        )
    }
}

