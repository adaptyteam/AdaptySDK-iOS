//
//  Schema.StringReference.TagValue.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 04.03.2026.
//

import Foundation

extension Schema.StringReference.TagValue: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(String.self) {
            self = .value(value)
            return
        }

        if let variable = try? container.decode(Schema.Variable.self) {
            self = .variable(variable)
            return
        }

        throw DecodingError.dataCorrupted(.init(codingPath: container.codingPath, debugDescription: "must be string, or variable"))
    }

}
