//
//  Schema.TextField.Placeholder.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 12.03.2026.
//

import Foundation

extension Schema.TextField.Placeholder: Decodable {
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

}
