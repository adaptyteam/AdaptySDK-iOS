//
//  Schema.Button.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension Schema {
    struct Button: Sendable {
        let actions: [Schema.Action]
        let normalState: Schema.Element
        let selectedState: Schema.Element?
        let isSelectedState: Schema.Variable?
    }
}

extension Schema.Button: Schema.CompositeElement {
    @inlinable
    func planTasks(in taskStack: inout Schema.ConfigurationBuilder.TasksStack) {
        taskStack.append(.planElement(normalState))
        if let selectedState {
            taskStack.append(.planElement(selectedState))
        }
    }

    @inlinable
    func buildElement(
        _: Schema.ConfigurationBuilder,
        _ properties: VC.Element.Properties?,
        _ resultStack: inout Schema.ConfigurationBuilder.ResultStack
    ) throws(Schema.Error) -> VC.Element {
        try .button(
            .init(
                actions: actions,
                normalState: resultStack.popLastElement(),
                selectedState: resultStack.popLastElement(selectedState != nil),
                isSelectedState: isSelectedState
            ),
            properties
        )
    }
}

extension Schema.Button: DecodableWithConfiguration {
    enum CodingKeys: String, CodingKey {
        case actions = "action"
        case normalState = "normal"
        case selectedState = "selected"
        case isSelectedState = "is_selected"
        case legacySelectedCondition = "selected_condition"
    }

    init(from decoder: Decoder, configuration: Schema.DecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        guard configuration.isLegacy else {
            try self.init(
                actions: container.decodeActions(forKey: .actions),
                normalState: container.decode(Schema.Element.self, forKey: .normalState, configuration: configuration),
                selectedState: container.decodeIfExist(Schema.Element.self, forKey: .selectedState, configuration: configuration),
                isSelectedState: container.decodeIfPresent(Schema.Variable.self, forKey: .isSelectedState)
            )
            return
        }

        let legacySelectedCondition = try container.decodeIfPresent(
            Schema.LegacyStateCondition.self,
            forKey: .legacySelectedCondition
        )

        let isSelectedState: Schema.Variable? =
            switch legacySelectedCondition {
            case let .selectedProduct(productId, groupId):
                .init(
                    path: ["Legacy", "productGroup", groupId],
                    setter: nil,
                    scope: .global,
                    converter: Schema.Variable.IsEqualConvertor(value: Schema.AnyValue(productId), falseValue: nil)
                )
            case let .selectedSection(sectionId, index):
                .init(
                    path: ["Legacy", "sections", sectionId],
                    setter: nil,
                    scope: .global,
                    converter: Schema.Variable.IsEqualConvertor(value: Schema.AnyValue(index), falseValue: nil)
                )
            default:
                nil
            }

        try self.init(
            actions: container.decodeActions(forKey: .actions),
            normalState: container.decode(Schema.Element.self, forKey: .normalState, configuration: configuration),
            selectedState: container.decodeIfExist(Schema.Element.self, forKey: .selectedState, configuration: configuration),
            isSelectedState: isSelectedState
        )
    }
}

