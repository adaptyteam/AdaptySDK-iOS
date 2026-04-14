//
//  Schema.Variable.IsEqualConvertor.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 13.04.2026.
//

import Foundation

extension Schema.Variable.IsEqualConvertor: Decodable {
    private enum CodingKeys: String, CodingKey {
        case value
        case falseValue = "false_value"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: Schema.Variable.CodingKeys.self)

        if let value = try? container.decode(Schema.AnyValue.self, forKeys: .converterParameters), !value.isObject {
            self.init(value: value, falseValue: nil)
            return
        }

        let params = try container.nestedContainer(keyedBy: CodingKeys.self, forKeys: .converterParameters)

        try self.init(
            value: params.decode(Schema.AnyValue.self, forKeys: .value),
            falseValue: params.decodeIfPresent(Schema.AnyValue.self, forKeys: .falseValue)
        )
    }
}

