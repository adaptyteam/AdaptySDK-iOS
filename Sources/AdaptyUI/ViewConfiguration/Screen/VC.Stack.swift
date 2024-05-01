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
        let elements: [AdaptyUI.ViewConfiguration.Element]
    }
}

extension AdaptyUI.ViewConfiguration.Localizer {
    func stack(_ from: AdaptyUI.ViewConfiguration.Stack) -> AdaptyUI.Stack {
        .init(
            type: from.type,
            horizontalAlignment: from.horizontalAlignment,
            verticalAlignment: from.verticalAlignment,
            elements: from.elements.map(element)
        )
    }
}

extension AdaptyUI.ViewConfiguration.Stack: Decodable {
    enum CodingKeys: String, CodingKey {
        case type
        case horizontalAlignment = "h_align"
        case verticalAlignment = "v_align"
        case elements
    }

    init(from decoder: any Decoder) throws {
        let def = AdaptyUI.Stack.default
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            type: container.decodeIfPresent(AdaptyUI.StackType.self, forKey: .type) ?? def.type,
            horizontalAlignment: container.decodeIfPresent(AdaptyUI.HorizontalAlignment.self, forKey: .horizontalAlignment) ?? def.horizontalAlignment,
            verticalAlignment: container.decodeIfPresent(AdaptyUI.VerticalAlignment.self, forKey: .verticalAlignment) ?? def.verticalAlignment,
            elements: container.decodeIfPresent([AdaptyUI.ViewConfiguration.Element].self, forKey: .elements) ?? []
        )
    }
}

extension AdaptyUI.StackType: Decodable {}
