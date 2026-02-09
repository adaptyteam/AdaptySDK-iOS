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

extension Schema.Variable: Codable {
    private enum CodingKeys: String, CodingKey {
        case path = "var"
        case setter
        case scope
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let path = try container.decode(String.self, forKey: .path)
        try self.init(
            path: path.split(separator: ".").map(String.init),
            setter: container.decodeIfPresent(String.self, forKey: .setter),
            scope: container.decodeIfPresent(Schema.Context.self, forKey: .scope) ?? .default
        )
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(path.joined(separator: "."), forKey: .path)
        try container.encodeIfPresent(setter, forKey: .setter)
        if scope != .default {
            try container.encode(scope, forKey: .scope)
        }
    }
}
