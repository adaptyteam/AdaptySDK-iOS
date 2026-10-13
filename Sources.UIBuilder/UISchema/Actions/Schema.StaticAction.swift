//
//  Schema.StaticAction.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 04.09.2026.
//

import AdaptyCodable
import Foundation

extension Schema {
    typealias StaticAction = VC.StaticAction
}

extension Schema.StaticAction: Decodable {
    package init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let function = try container.decode(String.self)
        let path = function.split(separator: ".").map(String.init)
        guard path.isNotEmpty else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "not found function name"
            )
        }
        self.init(path: path)
    }
}
