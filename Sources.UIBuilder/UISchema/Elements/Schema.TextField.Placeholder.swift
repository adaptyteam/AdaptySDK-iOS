//
//  Schema.TextField.Placeholder.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 12.03.2026.
//

import Foundation

extension Schema.TextField.Placeholder: Codable {
    enum CodingKeys: String, CodingKey {
        case stringId = "string_id"
        case overflowMode = "on_overflow"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        value = try container.decode(Schema.StringReference.self, forKey: .stringId)

        overflowMode =
            if let value = try? container.decode(Schema.Text.OverflowMode.self, forKey: .overflowMode) {
                Set([value])
            } else {
                try Set(container.decodeIfPresent([Schema.Text.OverflowMode].self, forKey: .overflowMode) ?? [])
            }

        let textAttributes = try Schema.TextAttributes(from: decoder)
        defaultTextAttributes = textAttributes.nonEmptyOrNil
    }

    func encode(to encoder: any Encoder) throws {
        if let defaultTextAttributes = defaultTextAttributes.nonEmptyOrNil {
            try defaultTextAttributes.encode(to: encoder)
        }
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .stringId)

        if let first = overflowMode.first {
            if overflowMode.count == 1 {
                try container.encode(first, forKey: .overflowMode)
            } else {
                try container.encode(overflowMode, forKey: .overflowMode)
            }
        }
    }
}
