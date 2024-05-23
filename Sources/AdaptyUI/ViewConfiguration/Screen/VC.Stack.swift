//
//  VC.Stack.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 28.03.2024
//
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    struct Stack {
        let type: AdaptyUI.StackType
        let horizontalAlignment: AdaptyUI.HorizontalAlignment
        let verticalAlignment: AdaptyUI.VerticalAlignment
        let spacing: Double
        let content: [AdaptyUI.ViewConfiguration.Element]
    }
}

extension AdaptyUI.ViewConfiguration.Localizer {
    func stack(_ from: AdaptyUI.ViewConfiguration.Stack) -> AdaptyUI.Stack {
        .init(
            type: from.type,
            horizontalAlignment: from.horizontalAlignment,
            verticalAlignment: from.verticalAlignment,
            spacing: from.spacing,
            content: from.content.map(element)
        )
    }
}

extension AdaptyUI.ViewConfiguration.Stack: Decodable {
    enum CodingKeys: String, CodingKey {
        case type
        case horizontalAlignment = "h_align"
        case verticalAlignment = "v_align"
        case spacing
        case content
    }

    init(from decoder: any Decoder) throws {
        let def = AdaptyUI.Stack.default
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            type: container.decode(AdaptyUI.StackType.self, forKey: .type),
            horizontalAlignment: container.decodeIfPresent(AdaptyUI.HorizontalAlignment.self, forKey: .horizontalAlignment) ?? def.horizontalAlignment,
            verticalAlignment: container.decodeIfPresent(AdaptyUI.VerticalAlignment.self, forKey: .verticalAlignment) ?? def.verticalAlignment,
            spacing: container.decodeIfPresent(Double.self, forKey: .spacing) ?? 0,
            content: container.decode([AdaptyUI.ViewConfiguration.Element].self, forKey: .content)
        )
    }
}

extension AdaptyUI.StackType: Decodable {}
