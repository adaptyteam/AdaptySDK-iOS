//
//  Schema.TextField.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 14.01.2026.
//

import Foundation

extension Schema {
    typealias TextField = VC.TextField
//    struct TextField: Sendable, Hashable {
//        let value: Variable
//        let horizontalAlign: HorizontalAlignment
//        let maxRows: Int?
//        let overflowMode: Set<Text.OverflowMode>
//        let defaultTextAttributes: RichText.Attributes?
//    }
}

extension Schema.TextField: Codable {
    enum CodingKeys: String, CodingKey {
        case value
        case horizontalAlign = "align"
        case maxRows = "max_rows"
        case overflowMode = "on_overflow"
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        value = try container.decode(Schema.Variable.self, forKey: .value)
        horizontalAlign = try container.decodeIfPresent(Schema.HorizontalAlignment.self, forKey: .horizontalAlign) ?? .leading
        maxRows = try container.decodeIfPresent(Int.self, forKey: .maxRows)
        overflowMode =
            if let value = try? container.decode(Schema.Text.OverflowMode.self, forKey: .overflowMode) {
                Set([value])
            } else {
                try Set(container.decodeIfPresent([Schema.Text.OverflowMode].self, forKey: .overflowMode) ?? [])
            }
        let textAttributes = try Schema.RichText.Attributes(from: decoder)
        defaultTextAttributes = textAttributes.nonEmptyOrNil
    }

    package func encode(to encoder: any Encoder) throws {
        if let defaultTextAttributes = defaultTextAttributes.nonEmptyOrNil {
            try defaultTextAttributes.encode(to: encoder)
        }
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
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
