//
//  Schema.FlexStack.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 04.06.2026.
//

import Foundation

extension Schema {
    struct FlexStack: Sendable {
        typealias Item = Schema.Stack.Item
        let condition: [VC.Condition]
        let direction: Schema.Flex.Direction
        let horizontalAlignment: HorizontalAlignment
        let verticalAlignment: VerticalAlignment
        let horizontalSpacing: Double
        let verticalSpacing: Double
        let items: [Item]
        let transition: Transition?
    }
}

extension Schema.FlexStack: Schema.CompositeElement {
    @inlinable
    func planTasks(in taskStack: inout Schema.ConfigurationBuilder.TasksStack) {
        for item in items.reversed() {
            if case let .element(el) = item {
                taskStack.append(.planElement(el))
            }
        }
    }

    @inlinable
    func buildElement(
        _ builder: Schema.ConfigurationBuilder,
        _ properties: VC.Element.Properties?,
        _ elementIndices: inout [VC.ElementIndex]
    ) throws(Schema.Error) -> VC.Element {
        let itemsCount = items.count { item in
            if case .element = item { true } else { false }
        }
        return try .flexStack(
            .init(
                condition: condition,
                direction: direction,
                horizontalAlignment: horizontalAlignment,
                verticalAlignment: verticalAlignment,
                horizontalSpacing: horizontalSpacing,
                verticalSpacing: verticalSpacing,
                items: builder.convertStackItems(items, elementIndices.pop(itemsCount)),
                transition: transition
            ),
            properties
        )
    }
}

extension Schema.FlexStack: DecodableWithConfiguration {
    enum CodingKeys: String, CodingKey {
        case condition
        case direction
        case horizontalAlignment = "h_align"
        case verticalAlignment = "v_align"
        case horizontalSpacing = "h_spacing"
        case verticalSpacing = "v_spacing"
        case duration
        case interpolator
        case content
    }

    init(from decoder: Decoder, configuration: Schema.InternalDecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let condition = try container.decode([Schema.Condition].self, forKey: .condition, configuration: configuration).asConditions

        let direction: Schema.Flex.Direction =
            switch try container.decode(String.self, forKey: .direction) {
            case "h_stack", "horizontal": condition == nil ? .vertical : .horizontal
            case "v_stack", "vertical": condition == nil ? .horizontal : .vertical
            default:
                throw DecodingError.dataCorruptedError(forKey: .direction, in: container, debugDescription: "Invalid direction")
            }

        let transition: Schema.Transition? =
            if condition?.isNotEmpty ?? false, container.exist(.duration) {
                try .init(
                    startDelay: 0,
                    duration: container.decode(Double.self, forKey: .duration) / 1000.0,
                    interpolator: container.decodeIfPresent(VC.Animation.Interpolator.self, forKey: .interpolator) ?? .default
                )
            } else {
                nil
            }

        try self.init(
            condition: condition ?? [],
            direction: direction,
            horizontalAlignment: container.decodeIfPresent(Schema.HorizontalAlignment.self, forKey: .horizontalAlignment)
                ?? Schema.Stack.default.horizontalAlignment,
            verticalAlignment: container.decodeIfPresent(Schema.VerticalAlignment.self, forKey: .verticalAlignment)
                ?? Schema.Stack.default.verticalAlignment,
            horizontalSpacing: container.decodeIfPresent(Double.self, forKey: .horizontalSpacing) ?? 0,
            verticalSpacing: container.decodeIfPresent(Double.self, forKey: .verticalSpacing) ?? 0,
            items: container.decode([Item].self, forKey: .content, configuration: configuration),
            transition: transition
        )
    }
}

