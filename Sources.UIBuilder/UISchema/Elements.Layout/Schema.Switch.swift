//
//  Schema.Switch.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 04.06.2026.
//

import Foundation

extension Schema {
    struct Switch: Sendable {
        let cases: [Case]
        let `default`: Schema.Element
        let transition: Transition?
    }

    struct Case: Sendable {
        let condition: [VC.Condition]
        let content: Schema.Element?
    }
}

extension Schema.Switch: Schema.CompositeElement {
    @inlinable
    func planTasks(in taskStack: inout Schema.ConfigurationBuilder.TasksStack) {
        for item in cases.reversed() {
            if let content = item.content {
                taskStack.append(.planElement(content))
            }
        }
        taskStack.append(.planElement(`default`))
    }

    @inlinable
    func buildElement(
        _: Schema.ConfigurationBuilder,
        _ properties: VC.Element.Properties?,
        _ elementIndices: inout [VC.ElementIndex]
    ) throws(Schema.Error) -> VC.Element {
        let zipped = try zip(cases, elementIndices.pop(cases.count))

        let items: [VC.Case] = zipped.map { item, elementIndex in
            .init(
                condition: item.condition,
                content: elementIndex
            )
        }

        return try .switch(
            .init(
                cases: items,
                default: elementIndices.pop(),
                transition: transition
            ),
            properties
        )
    }
}

extension Schema.Switch: DecodableWithConfiguration {
    enum CodingKeys: String, CodingKey {
        case cases
        case `default`
        case duration
        case interpolator
    }

    init(from decoder: Decoder, configuration: Schema.InternalDecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let cases = try container.decode([Schema.Case].self, forKeys: .cases, configuration: configuration)

        var alwaysTrueElement: Schema.Element? = .none
        let compactCases: [Schema.Case] = cases.compactMap { item in
            guard alwaysTrueElement == nil, let content = item.content else { return nil }
            if item.condition.isEmpty { // always true
                alwaysTrueElement = content
                return nil
            } else {
                return item
            }
        }

        let defaultElement: Schema.Element =
            if let alwaysTrueElement {
                alwaysTrueElement
            } else {
                try container.decode(Schema.Element.self, forKey: .default, configuration: configuration)
            }

        let transition: Schema.Transition? =
            if compactCases.isNotEmpty, container.exist(.duration) {
                try .init(
                    startDelay: 0,
                    duration: container.decode(Double.self, forKey: .duration) / 1000.0,
                    interpolator: container.decodeIfPresent(VC.Animation.Interpolator.self, forKey: .interpolator) ?? .default
                )
            } else {
                nil
            }

        self.init(
            cases: compactCases,
            default: defaultElement,
            transition: transition
        )
    }
}

extension Schema.Case: DecodableWithConfiguration {
    enum CodingKeys: String, CodingKey {
        case condition
        case content
    }

    init(from decoder: Decoder, configuration: Schema.InternalDecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let condition = try container.decode([Schema.Condition].self, forKey: .condition, configuration: configuration).asConditions {
            try self.init(
                condition: condition,
                content: container.decode(Schema.Element.self, forKey: .content, configuration: configuration)
            )
        } else {
            self.init(
                condition: [],
                content: nil
            )
        }
    }
}

