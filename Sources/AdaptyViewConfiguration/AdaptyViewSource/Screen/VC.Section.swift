//
//  VC.Section.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension AdaptyViewSource {
    struct Section: Sendable, Hashable {
        let id: String
        let index: Int
        let content: [AdaptyViewSource.Element]
    }
}

extension AdaptyViewSource.Localizer {
    func section(_ from: AdaptyViewSource.Section) throws -> AdaptyViewConfiguration.Section {
        try .init(
            id: from.id,
            index: from.index,
            content: from.content.map(element)
        )
    }
}

extension AdaptyViewSource.Section: Decodable {
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
            content: container.decode([AdaptyViewSource.Element].self, forKey: .content)
        )
    }
}
