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

extension Schema.Text: Codable {
    enum CodingKeys: String, CodingKey {
        case stringId = "string_id"
        case horizontalAlign = "align"
        case maxRows = "max_rows"
        case overflowMode = "on_overflow"
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let overflowMode =
            if let value = try? container.decode(OverflowMode.self, forKey: .overflowMode) {
                Set([value])
            } else {
                try Set(container.decodeIfPresent([OverflowMode].self, forKey: .overflowMode) ?? [])
            }

        let textAttributes = try Schema.Text.Attributes(from: decoder)

        try self.init(
            value: container.decode(Schema.StringReference.self, forKey: .stringId),
            horizontalAlign: container.decodeIfPresent(Schema.HorizontalAlignment.self, forKey: .horizontalAlign) ?? .leading,
            maxRows: container.decodeIfPresent(Int.self, forKey: .maxRows),
            overflowMode: overflowMode,
            defaultTextAttributes: textAttributes.nonEmptyOrNil
        )
    }

    package func encode(to encoder: any Encoder) throws {
        if let defaultTextAttributes = defaultTextAttributes.nonEmptyOrNil {
            try defaultTextAttributes.encode(to: encoder)
        }
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .stringId)
        if horizontalAlign != .leading {
            try container.encode(horizontalAlign, forKey: .horizontalAlign)
        }
        try container.encodeIfPresent(maxRows, forKey: .maxRows)
        if let first = overflowMode.first {
            if overflowMode.count == 1 {
                try container.encode(first, forKey: .overflowMode)
            } else {
                try container.encode(overflowMode, forKey: .overflowMode)
            }
        }
    }
}
