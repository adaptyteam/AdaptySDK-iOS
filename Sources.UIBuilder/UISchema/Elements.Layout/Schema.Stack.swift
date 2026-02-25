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

extension Schema.Localizer {
    func planStack(
        _ stack: Schema.Stack,
        _ properties: Schema.Element.Properties?,
        in workStack: inout [WorkItem]
    ) throws {
        workStack.append(.buildStack(stack, properties))
        for item in stack.items.reversed() {
            if case let .element(el) = item {
                workStack.append(.planElement(el))
            }
        }
    }

    func buildStack(
        _ from: Schema.Stack,
        _ properties: Schema.Element.Properties?,
        in resultStack: inout [VC.Element]
    ) {
        var elementCount = 0
        for item in from.items {
            if case .element = item { elementCount += 1 }
        }
        var elements = [VC.Element]()
        elements.reserveCapacity(elementCount)
        for _ in 0 ..< elementCount {
            elements.append(resultStack.removeLast())
        }
        elements.reverse()

        var vcItems = [VC.Stack.Item]()
        vcItems.reserveCapacity(from.items.count)
        var elementIndex = 0
        for item in from.items {
            switch item {
            case let .space(value):
                vcItems.append(.space(value))
            case .element:
                vcItems.append(.element(elements[elementIndex]))
                elementIndex += 1
            }
        }
        resultStack.append(.stack(
            .init(
                type: from.type,
                horizontalAlignment: from.horizontalAlignment,
                verticalAlignment: from.verticalAlignment,
                spacing: from.spacing,
                items: vcItems
            ),
            properties?.value
        ))
    }

//    private func old_stackItem(_ from: Schema.Stack.Item) throws -> VC.Stack.Item {
//        switch from {
//        case let .space(value):
//            .space(value)
//        case let .element(value):
//            try .element(old_element(value))
//        }
//    }
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
