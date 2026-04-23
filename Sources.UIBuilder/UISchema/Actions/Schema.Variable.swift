//
//  Schema.Variable.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 14.01.2026.
//

import Foundation

extension Schema {
    typealias Variable = VC.Variable
}

extension Schema.Variable: Decodable {
    enum CodingKeys: String, CodingKey {
        case path = "var"
        case setter
        case scope
        case converter
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let path = try container.decode(String.self, forKey: .path)

        let converter: Schema.AnyConverter? =
            if container.exist(.converter) {
                try Schema.AnyConverter.forDataBinding(from: decoder)
            } else {
                nil
            }

        try self.init(
            path: path.split(separator: ".").map(String.init),
            setter: container.decodeIfPresent(String.self, forKey: .setter),
            scope: container.decodeIfPresent(Schema.Context.self, forKey: .scope) ?? .default,
            converter: converter
        )
    }
}

