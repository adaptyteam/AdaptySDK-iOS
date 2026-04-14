//
//  Schema.WheelItemsPicker.Item.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 15.03.2026.
//

import Foundation

extension Schema.WheelItemsPicker.Item: Decodable {
    enum CodingKeys: String, CodingKey {
        case stringId = "string_id"
        case value
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let value = try container.decode(Schema.AnyValue.self, forKey: .value)

        if value.isArray || value.isObject {
            throw DecodingError.dataCorruptedError(
                forKey: .value,
                in: container,
                debugDescription: "value must be a primitive type (string, bool, int32, uint32, or double)"
            )
        }

        try self.init(
            stringId: container.decode(VC.StringIdentifier.self, forKey: .stringId),
            value: value
        )
    }
}
