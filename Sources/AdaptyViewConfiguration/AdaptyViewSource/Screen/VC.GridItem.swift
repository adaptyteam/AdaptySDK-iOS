//
//  VC.GridItem.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension AdaptyViewSource {
    struct GridItem: Sendable, Hashable {
        let length: AdaptyViewConfiguration.GridItem.Length
        let horizontalAlignment: AdaptyViewConfiguration.HorizontalAlignment
        let verticalAlignment: AdaptyViewConfiguration.VerticalAlignment
        let content: AdaptyViewSource.Element
    }
}

extension AdaptyViewSource.Localizer {
    func gridItem(_ from: AdaptyViewSource.GridItem) throws -> AdaptyViewConfiguration.GridItem {
        try .init(
            length: from.length,
            horizontalAlignment: from.horizontalAlignment,
            verticalAlignment: from.verticalAlignment,
            content: element(from.content)
        )
    }
}

extension AdaptyViewSource.GridItem: Decodable {
    enum CodingKeys: String, CodingKey {
        case fixed
        case weight
        case horizontalAlignment = "h_align"
        case verticalAlignment = "v_align"
        case content
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let length: AdaptyViewConfiguration.GridItem.Length =
            if let value = try container.decodeIfPresent(Int.self, forKey: .weight) {
                .weight(value)
            } else {
                try .fixed(container.decode(AdaptyViewConfiguration.Unit.self, forKey: .fixed))
            }

        try self.init(
            length: length,
            horizontalAlignment: container.decodeIfPresent(AdaptyViewConfiguration.HorizontalAlignment.self, forKey: .horizontalAlignment) ?? AdaptyViewConfiguration.GridItem.defaultHorizontalAlignment,
            verticalAlignment: container.decodeIfPresent(AdaptyViewConfiguration.VerticalAlignment.self, forKey: .verticalAlignment) ?? AdaptyViewConfiguration.GridItem.defaultVerticalAlignment,
            content: container.decode(AdaptyViewSource.Element.self, forKey: .content)
        )
    }
}
