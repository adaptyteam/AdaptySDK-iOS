//
//  Schema.Stack.Item.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 01.12.2025.
//

import Foundation

extension Schema.Stack {
    enum Item: Sendable {
        case space(Int)
        case element(Schema.Element)
    }
}

extension Schema.Stack.Item: Decodable {
    enum CodingKeys: String, CodingKey {
        case type
        case count
    }

    enum ContentType: String, Codable {
        case space
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        guard let contentType = ContentType(rawValue: type) else {
            self = try .element(Schema.Element(from: decoder))
            return
        }

        switch contentType {
        case .space:
            self = try .space(container.decodeIfPresent(Int.self, forKey: .count) ?? 1)
        }
    }
}
