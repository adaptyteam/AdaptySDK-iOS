//
//  VC.Section.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 28.03.2024
//
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    struct Section: Sendable, Hashable {
        let id: String
        let index: Int
        let content: [AdaptyUI.ViewConfiguration.Element]
    }
}

extension AdaptyUI.ViewConfiguration.Localizer {
    func section(_ from: AdaptyUI.ViewConfiguration.Section) throws -> AdaptyUI.Section {
        try .init(
            id: from.id,
            index: from.index,
            content: from.content.map(element)
        )
    }
}

extension AdaptyUI.ViewConfiguration.Section: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case index
        case content
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            id: container.decode(String.self, forKey: .id),
            index: container.decodeIfPresent(Int.self, forKey: .index) ?? 0,
            content: container.decode([AdaptyUI.ViewConfiguration.Element].self, forKey: .content)
        )
    }
}
