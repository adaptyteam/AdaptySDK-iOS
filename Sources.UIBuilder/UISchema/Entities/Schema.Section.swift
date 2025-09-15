//
//  Schema.Section.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension Schema {
    struct Section: Sendable {
        let id: String
        let index: Int
        let content: [Schema.Element]
    }
}

extension Schema.Localizer {
    func section(_ from: Schema.Section) throws -> AdaptyUIConfiguration.Section {
        try .init(
            id: from.id,
            index: from.index,
            content: from.content.map(element)
        )
    }
}

extension Schema.Section: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case index
        case content
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            id: container.decode(String.self, forKey: .id),
            index: container.decodeIfPresent(Int.self, forKey: .index) ?? 0,
            content: container.decode([Schema.Element].self, forKey: .content)
        )
    }
}
