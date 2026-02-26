//
//  Schema.Stack.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension Schema {
    struct Stack: Sendable, Hashable {
        let type: Kind
        let horizontalAlignment: HorizontalAlignment
        let verticalAlignment: VerticalAlignment
        let spacing: Double
        let items: [Item]
    }
}

extension Schema.Stack {
    static let `default` = Self(
        type: .vertical,
        horizontalAlignment: .center,
        verticalAlignment: .center,
        spacing: 0,
        items: []
    )
}

extension Schema.ConfigurationBuilder {
    @inlinable
    func planStack(
        _ stack: Schema.Stack,
        _ properties: VC.Element.Properties?,
        in taskStack: inout [Task]
    ) {
        taskStack.append(.buildStack(stack, properties))
        for item in stack.items.reversed() {
            if case let .element(el) = item {
                taskStack.append(.planElement(el))
            }
        }
    }

    @inlinable
    func buildStack(
        _ from: Schema.Stack,
        _ elementStack: inout [VC.Element]
    ) throws(Schema.Error) -> VC.Stack {
        let elementCount = from.items.count { item in
            if case .element = item { true } else { false }
        }
        let elements = try elementStack.popLastElements(elementCount)
        return .init(
            type: from.type,
            horizontalAlignment: from.horizontalAlignment,
            verticalAlignment: from.verticalAlignment,
            spacing: from.spacing,
            items: buildStackItems(from.items, elements)
        )
    }

    @inlinable
    func buildStackItems(
        _ items: [Schema.Stack.Item],
        _ elements: [VC.Element]
    ) -> [VC.Stack.Item] {
        var stackItems = [VC.Stack.Item]()
        stackItems.reserveCapacity(elements.count)
        var elementIndex = 0
        for item in items {
            switch item {
            case let .space(value):
                stackItems.append(.space(value))
            case .element:
                stackItems.append(.element(elements[elementIndex]))
                elementIndex += 1
            }
        }
        return stackItems
    }
}

extension Schema.Stack: DecodableWithConfiguration {
    enum CodingKeys: String, CodingKey {
        case type
        case horizontalAlignment = "h_align"
        case verticalAlignment = "v_align"
        case spacing
        case content
    }

    init(from decoder: Decoder, configuration: Schema.DecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            type: container.decode(Kind.self, forKey: .type),
            horizontalAlignment: container.decodeIfPresent(Schema.HorizontalAlignment.self, forKey: .horizontalAlignment)
                ?? Self.default.horizontalAlignment,
            verticalAlignment: container.decodeIfPresent(Schema.VerticalAlignment.self, forKey: .verticalAlignment)
                ?? Self.default.verticalAlignment,
            spacing: container.decodeIfPresent(Double.self, forKey: .spacing) ?? 0,
            items: container.decode([Item].self, forKey: .content, configuration: configuration)
        )
    }
}
