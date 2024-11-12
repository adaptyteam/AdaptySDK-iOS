//
//  VC.Stack.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 28.03.2024
//
//

import Foundation

extension AdaptyUICore.ViewConfiguration {
    struct Stack: Hashable, Sendable {
        let type: AdaptyUICore.StackType
        let horizontalAlignment: AdaptyUICore.HorizontalAlignment
        let verticalAlignment: AdaptyUICore.VerticalAlignment
        let spacing: Double
        let items: [StackItem]
    }

    enum StackItem: Sendable {
        case space(Int)
        case element(AdaptyUICore.ViewConfiguration.Element)
    }
}

extension AdaptyUICore.ViewConfiguration.Localizer {
    private func stackItem(_ from: AdaptyUICore.ViewConfiguration.StackItem) throws -> AdaptyUICore.StackItem {
        switch from {
        case let .space(value):
            .space(value)
        case let .element(value):
            try .element(element(value))
        }
    }

    func stack(_ from: AdaptyUICore.ViewConfiguration.Stack) throws -> AdaptyUICore.Stack {
        try .init(
            type: from.type,
            horizontalAlignment: from.horizontalAlignment,
            verticalAlignment: from.verticalAlignment,
            spacing: from.spacing,
            items: from.items.map(stackItem)
        )
    }
}

extension AdaptyUICore.ViewConfiguration.StackItem: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .space(value):
            hasher.combine(1)
            hasher.combine(value)
        case let .element(value):
            hasher.combine(2)
            hasher.combine(value)
        }
    }
}

extension AdaptyUICore.ViewConfiguration.Stack: Decodable {
    enum CodingKeys: String, CodingKey {
        case type
        case horizontalAlignment = "h_align"
        case verticalAlignment = "v_align"
        case spacing
        case content
    }

    init(from decoder: Decoder) throws {
        let def = AdaptyUICore.Stack.default
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            type: container.decode(AdaptyUICore.StackType.self, forKey: .type),
            horizontalAlignment: container.decodeIfPresent(AdaptyUICore.HorizontalAlignment.self, forKey: .horizontalAlignment) ?? def.horizontalAlignment,
            verticalAlignment: container.decodeIfPresent(AdaptyUICore.VerticalAlignment.self, forKey: .verticalAlignment) ?? def.verticalAlignment,
            spacing: container.decodeIfPresent(Double.self, forKey: .spacing) ?? 0,
            items: container.decode([AdaptyUICore.ViewConfiguration.StackItem].self, forKey: .content)
        )
    }
}

extension AdaptyUICore.ViewConfiguration.StackItem: Decodable {
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
            self = try .element(AdaptyUICore.ViewConfiguration.Element(from: decoder))
            return
        }

        switch contentType {
        case .space:
            self = try .space(container.decodeIfPresent(Int.self, forKey: .count) ?? 1)
        }
    }
}

extension AdaptyUICore.StackType: Decodable {}
