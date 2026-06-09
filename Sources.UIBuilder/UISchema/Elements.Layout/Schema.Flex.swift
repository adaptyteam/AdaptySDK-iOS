//
//  Schema.Flex.swift
//  AdaptyUIBulder
//
//  Created by Aleksei Valiano on 04.06.2026.
//

import Foundation

extension Schema {
    struct Flex: Sendable {
        typealias Direction = VC.Flex.Direction
        let condition: [VC.Condition]
        let direction: Direction
        let width: AutoSizeMode
        let height: AutoSizeMode
        let horizontalSpacing: Double
        let verticalSpacing: Double
        let items: [GridItem]
        let transition: Transition?
    }
}

extension Schema.Flex: Schema.CompositeElement {
    @inlinable
    func planTasks(in taskStack: inout Schema.ConfigurationBuilder.TasksStack) {
        for item in items.reversed() {
            taskStack.append(.planElement(item.content))
        }
    }

    @inlinable
    func buildElement(
        _ builder: Schema.ConfigurationBuilder,
        _ properties: VC.Element.Properties?,
        _ elementIndices: inout [VC.ElementIndex]
    ) throws(Schema.Error) -> VC.Element {
        try .flex(
            .init(
                condition: condition,
                direction: direction,
                width: width,
                height: height,
                horizontalSpacing: horizontalSpacing,
                verticalSpacing: verticalSpacing,
                items: builder.convertGridItems(items, elementIndices.pop(items.count)),
                transition: transition
            ),
            properties
        )
    }
}

extension Schema.Flex: DecodableWithConfiguration {
    enum CodingKeys: String, CodingKey {
        case condition
        case direction
        case width
        case height
        case horizontalSpacing = "h_spacing"
        case verticalSpacing = "v_spacing"
        case duration
        case interpolator
        case items
    }

    init(from decoder: Decoder, configuration: Schema.InternalDecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let condition = try container.decode([Schema.Condition].self, forKey: .condition, configuration: configuration).asConditions

        let direction: Schema.Flex.Direction =
            switch try container.decode(String.self, forKey: .direction) {
            case "row", "horizontal": condition == nil ? .vertical : .horizontal
            case "column", "vertical": condition == nil ? .horizontal : .vertical
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
            width: container.decodeIfPresent(Schema.AutoSizeMode.self, forKey: .width) ?? .default,
            height: container.decodeIfPresent(Schema.AutoSizeMode.self, forKey: .height) ?? .default,
            horizontalSpacing: container.decodeIfPresent(Double.self, forKey: .horizontalSpacing) ?? 0,
            verticalSpacing: container.decodeIfPresent(Double.self, forKey: .verticalSpacing) ?? 0,
            items: container.decode([Schema.GridItem].self, forKey: .items, configuration: configuration),
            transition: transition
        )
    }
}

