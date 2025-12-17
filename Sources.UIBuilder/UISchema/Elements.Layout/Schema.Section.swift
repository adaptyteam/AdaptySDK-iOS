//
//  Schema.Section.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension Schema {
    struct Section: Sendable, Hashable {
        let id: String
        let index: Int32
        let content: [Schema.Element]
    }
}

extension Schema.Localizer {
    func section(_ from: Schema.Section) throws -> VC.Section {
        try .init(
            id: from.id,
            index: from.index,
            content: from.content.map(element)
        )
    }
}

extension Schema.Section: DecodableWithConfiguration {
    enum CodingKeys: String, CodingKey {
        case id
        case index
        case content
    }

    init(from decoder: Decoder, configuration: Schema.DecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            id: container.decode(String.self, forKey: .id),
            index: container.decodeIfPresent(Int32.self, forKey: .index) ?? 0,
            content: container.decode([Schema.Element].self, forKey: .content, configuration: configuration)
        )
    }
}
