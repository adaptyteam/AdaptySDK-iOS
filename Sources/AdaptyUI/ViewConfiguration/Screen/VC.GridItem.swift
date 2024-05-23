//
//  VC.GridItem.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 28.03.2024
//
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    struct GridItem {
        let length: AdaptyUI.GridItem.Length
        let horizontalAlignment: AdaptyUI.HorizontalAlignment
        let verticalAlignment: AdaptyUI.VerticalAlignment
        let content: AdaptyUI.ViewConfiguration.Element
    }
}

extension AdaptyUI.ViewConfiguration.Localizer {
    func gridItem(_ from: AdaptyUI.ViewConfiguration.GridItem) -> AdaptyUI.GridItem {
        .init(
            length: from.length,
            horizontalAlignment: from.horizontalAlignment,
            verticalAlignment: from.verticalAlignment,
            content: element(from.content)
        )
    }
}

extension AdaptyUI.ViewConfiguration.GridItem: Decodable {
    enum CodingKeys: String, CodingKey {
        case fixed
        case weight
        case horizontalAlignment = "h_align"
        case verticalAlignment = "v_align"
        case content
    }

    init(from decoder: any Decoder) throws {
        let conteiner = try decoder.container(keyedBy: CodingKeys.self)
        let length: AdaptyUI.GridItem.Length =
            if let value = try conteiner.decodeIfPresent(Int.self, forKey: .weight) {
                .weight(value)
            } else {
                try .fixed(conteiner.decode(AdaptyUI.Unit.self, forKey: .fixed))
            }

        try self.init(
            length: length,
            horizontalAlignment: conteiner.decodeIfPresent(AdaptyUI.HorizontalAlignment.self, forKey: .horizontalAlignment) ?? AdaptyUI.GridItem.defaultHorizontalAlignment,
            verticalAlignment: conteiner.decodeIfPresent(AdaptyUI.VerticalAlignment.self, forKey: .verticalAlignment) ?? AdaptyUI.GridItem.defaultVerticalAlignment,
            content: conteiner.decode(AdaptyUI.ViewConfiguration.Element.self, forKey: .content)
        )
    }
}
