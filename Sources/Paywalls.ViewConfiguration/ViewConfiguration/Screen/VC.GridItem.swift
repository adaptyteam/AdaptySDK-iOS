//
//  VC.GridItem.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 28.03.2024
//
//

import Foundation

extension AdaptyUICore.ViewConfiguration {
    struct GridItem: Sendable, Hashable {
        let length: AdaptyUICore.GridItem.Length
        let horizontalAlignment: AdaptyUICore.HorizontalAlignment
        let verticalAlignment: AdaptyUICore.VerticalAlignment
        let content: AdaptyUICore.ViewConfiguration.Element
    }
}

extension AdaptyUICore.ViewConfiguration.Localizer {
    func gridItem(_ from: AdaptyUICore.ViewConfiguration.GridItem) throws -> AdaptyUICore.GridItem {
        try .init(
            length: from.length,
            horizontalAlignment: from.horizontalAlignment,
            verticalAlignment: from.verticalAlignment,
            content: element(from.content)
        )
    }
}

extension AdaptyUICore.ViewConfiguration.GridItem: Decodable {
    enum CodingKeys: String, CodingKey {
        case fixed
        case weight
        case horizontalAlignment = "h_align"
        case verticalAlignment = "v_align"
        case content
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let length: AdaptyUICore.GridItem.Length =
            if let value = try container.decodeIfPresent(Int.self, forKey: .weight) {
                .weight(value)
            } else {
                try .fixed(container.decode(AdaptyUICore.Unit.self, forKey: .fixed))
            }

        try self.init(
            length: length,
            horizontalAlignment: container.decodeIfPresent(AdaptyUICore.HorizontalAlignment.self, forKey: .horizontalAlignment) ?? AdaptyUICore.GridItem.defaultHorizontalAlignment,
            verticalAlignment: container.decodeIfPresent(AdaptyUICore.VerticalAlignment.self, forKey: .verticalAlignment) ?? AdaptyUICore.GridItem.defaultVerticalAlignment,
            content: container.decode(AdaptyUICore.ViewConfiguration.Element.self, forKey: .content)
        )
    }
}
