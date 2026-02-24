//
//  Schema.Variable.Convertor.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 23.02.2026.
//

import Foundation

extension Schema.Variable.Converter: Codable {
    private enum CodingKeys: String, CodingKey {
        case name = "converter"
        case params = "converter_params"
    }

    private enum Names: String, Codable {
        case isEqual = "is_equal"
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let name = try container.decode(String.self, forKey: .name)
        let params = try container.decodeIfPresent(VC.Constant.self, forKey: .params)?.asOptional

        switch Names(rawValue: name) {
        case .isEqual:
            guard let params else {
                throw DecodingError.keyNotFound(CodingKeys.params, .init(codingPath: container.codingPath, debugDescription: "Not found required key"))
            }

            switch params {
            case .object(let object):
                guard let value = object["value"]?.asOptional else {
                    throw DecodingError.dataCorrupted(.init(codingPath: container.codingPath + [CodingKeys.params], debugDescription: "Not found `value` key"))
                }

                self = .isEqual(value, false: object["false_value"])
            default:
                self = .isEqual(params, false: nil)
            }

        case nil:
            self = try .unknown(name, params)
        }
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .isEqual(let value, let falseValue):
            try container.encode(Names.isEqual, forKey: .name)
            let params: VC.Constant =
                if let falseValue {
                    .object(["value": value, "false_value": falseValue])
                } else {
                    value
                }
            try container.encode(params, forKey: .params)
        case .unknown(let name, let params):
            try container.encode(name, forKey: .name)
            try container.encodeIfPresent(params, forKey: .params)
        }
    }
}
