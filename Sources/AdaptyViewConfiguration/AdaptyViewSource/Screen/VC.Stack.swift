//
//  VC.Stack.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension AdaptyViewSource {
    struct Stack: Hashable, Sendable {
        let type: AdaptyViewConfiguration.StackType
        let horizontalAlignment: AdaptyViewConfiguration.HorizontalAlignment
        let verticalAlignment: AdaptyViewConfiguration.VerticalAlignment
        let spacing: Double
        let items: [StackItem]
    }

    enum StackItem: Sendable {
        case space(Int)
        case element(AdaptyViewSource.Element)
    }
}

extension AdaptyViewSource.Localizer {
    private func stackItem(_ from: AdaptyViewSource.StackItem) throws -> AdaptyViewConfiguration.StackItem {
        switch from {
        case let .space(value):
            .space(value)
        case let .element(value):
            try .element(element(value))
        }
    }

    func stack(_ from: AdaptyViewSource.Stack) throws -> AdaptyViewConfiguration.Stack {
        try .init(
            type: from.type,
            horizontalAlignment: from.horizontalAlignment,
            verticalAlignment: from.verticalAlignment,
            spacing: from.spacing,
            items: from.items.map(stackItem)
        )
    }
}

extension AdaptyViewSource.StackItem: Hashable {
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

extension AdaptyViewSource.Stack: Decodable {
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
            items: container.decode([AdaptyViewSource.StackItem].self, forKey: .content)
        )
    }
}

extension AdaptyViewSource.StackItem: Decodable {
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
            self = try .element(AdaptyViewSource.Element(from: decoder))
            return
        }

        switch contentType {
        case .space:
            self = try .space(container.decodeIfPresent(Int.self, forKey: .count) ?? 1)
        }
    }
}

extension AdaptyViewConfiguration.StackType: Decodable {}
