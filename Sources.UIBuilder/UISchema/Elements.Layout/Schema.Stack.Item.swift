//
//  Schema.Stack.Item.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 01.12.2025.
//

import Foundation

extension Schema.Stack {
    enum Item: Sendable, Hashable {
        case space(Int)
        case element(Schema.Element)
    }
}

extension Schema.Stack.Item: DecodableWithConfiguration {
    static let typeForSpace = "space"
    
    enum CodingKeys: String, CodingKey {
        case type
        case count
    }

    init(from decoder: Decoder, configuration: Schema.DecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        if type == Self.typeForSpace {
            self = try .space(container.decodeIfPresent(Int.self, forKey: .count) ?? 1)
        } else {
            self = try .element(Schema.Element(from: decoder, configuration: configuration))
        }
    }
}
