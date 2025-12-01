//
//  Schema.Stack.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension Schema {
    struct Stack: Sendable {
        let type: Kind
        let horizontalAlignment: HorizontalAlignment
        let verticalAlignment: VerticalAlignment
        let spacing: Double
        let items: [Item]
    }
}

extension Schema.Stack {
    static let `default` = VC.Stack.default
}

extension Schema.Localizer {
    private func stackItem(_ from: Schema.Stack.Item) throws -> VC.Stack.Item {
        switch from {
        case let .space(value):
            .space(value)
        case let .element(value):
            try .element(element(value))
        }
    }

    func stack(_ from: Schema.Stack) throws -> VC.Stack {
        try .init(
            type: from.type,
            horizontalAlignment: from.horizontalAlignment,
            verticalAlignment: from.verticalAlignment,
            spacing: from.spacing,
            items: from.items.map(stackItem)
        )
    }
}

extension Schema.Stack: Decodable {
    enum CodingKeys: String, CodingKey {
        case type
        case horizontalAlignment = "h_align"
        case verticalAlignment = "v_align"
        case spacing
        case content
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            type: container.decode(Kind.self, forKey: .type),
            horizontalAlignment: container.decodeIfPresent(Schema.HorizontalAlignment.self, forKey: .horizontalAlignment)
                ?? Self.default.horizontalAlignment,
            verticalAlignment: container.decodeIfPresent(Schema.VerticalAlignment.self, forKey: .verticalAlignment)
                ?? Self.default.verticalAlignment,
            spacing: container.decodeIfPresent(Double.self, forKey: .spacing) ?? 0,
            items: container.decode([Item].self, forKey: .content)
        )
    }
}
