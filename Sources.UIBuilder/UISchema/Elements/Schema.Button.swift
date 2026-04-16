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
        let content: Schema.Element
        let legacySelectedContent: Schema.Element?
        let legacyIsSelected: Schema.Variable?
    }
}

extension Schema.Button: Schema.CompositeElement {
    @inlinable
    func planTasks(in taskStack: inout Schema.ConfigurationBuilder.TasksStack) {
        taskStack.append(.planElement(content))
        if let legacySelectedContent {
            taskStack.append(.planElement(legacySelectedContent))
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
                content: resultStack.popLastElement(),
                legacySelectedContent: resultStack.popLastElement(legacySelectedContent != nil),
                legacyIsSelected: legacyIsSelected
            ),
            properties
        )
    }
}

extension Schema.Button: DecodableWithConfiguration {
    enum CodingKeys: String, CodingKey {
        case actions = "action"
        case content
        case legacyNormalContent = "normal"
        case legacySelectedContent = "selected"
        case legacyIsSelected = "is_selected"
        case legacySelectedCondition = "selected_condition"
    }

    init(from decoder: Decoder, configuration: Schema.DecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        guard configuration.isLegacy else {
            let contentKey: CodingKeys =
                if container.contains(.content), !container.contains(.legacyNormalContent)
                { .content } else { .legacyNormalContent }
            try self.init(
                actions: container.decodeActions(forKey: .actions),
                content: container.decode(Schema.Element.self, forKey: contentKey, configuration: configuration),
                legacySelectedContent: container.decodeIfExist(Schema.Element.self, forKey: .legacySelectedContent, configuration: configuration),
                legacyIsSelected: container.decodeIfPresent(Schema.Variable.self, forKey: .legacyIsSelected)
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
            content: container.decode(Schema.Element.self, forKey: .legacyNormalContent, configuration: configuration),
            legacySelectedContent: container.decodeIfExist(Schema.Element.self, forKey: .legacySelectedContent, configuration: configuration),
            legacyIsSelected: isSelectedState
        )
    }
}

