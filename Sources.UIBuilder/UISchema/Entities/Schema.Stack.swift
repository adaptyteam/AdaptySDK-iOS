//
//  Schema.Stack.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension Schema {
    struct Stack: Sendable {
        let type: AdaptyViewConfiguration.StackType
        let horizontalAlignment: AdaptyViewConfiguration.HorizontalAlignment
        let verticalAlignment: AdaptyViewConfiguration.VerticalAlignment
        let spacing: Double
        let items: [StackItem]
    }

    enum StackItem: Sendable {
        case space(Int)
        case element(Schema.Element)
    }
}

extension Schema.Localizer {
    private func stackItem(_ from: Schema.StackItem) throws -> AdaptyViewConfiguration.StackItem {
        switch from {
        case let .space(value):
            .space(value)
        case let .element(value):
            try .element(element(value))
        }
    }

    func stack(_ from: Schema.Stack) throws -> AdaptyViewConfiguration.Stack {
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
        let def = AdaptyViewConfiguration.Stack.default
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            type: container.decode(AdaptyViewConfiguration.StackType.self, forKey: .type),
            horizontalAlignment: container.decodeIfPresent(AdaptyViewConfiguration.HorizontalAlignment.self, forKey: .horizontalAlignment) ?? def.horizontalAlignment,
            verticalAlignment: container.decodeIfPresent(AdaptyViewConfiguration.VerticalAlignment.self, forKey: .verticalAlignment) ?? def.verticalAlignment,
            spacing: container.decodeIfPresent(Double.self, forKey: .spacing) ?? 0,
            items: container.decode([Schema.StackItem].self, forKey: .content)
        )
    }
}

extension Schema.StackItem: Decodable {
    enum CodingKeys: String, CodingKey {
        case type
        case count
    }

    enum ContentType: String, Codable {
        case space
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        guard let contentType = ContentType(rawValue: type) else {
            self = try .element(Schema.Element(from: decoder))
            return
        }

        switch contentType {
        case .space:
            self = try .space(container.decodeIfPresent(Int.self, forKey: .count) ?? 1)
        }
    }
}

extension AdaptyViewConfiguration.StackType: Decodable {}
