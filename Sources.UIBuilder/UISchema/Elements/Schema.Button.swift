//
//  Schema.Button.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension Schema {
    struct Button: Sendable, Hashable {
        let actions: [Schema.Action]
        let normalState: Schema.Element
        let selectedState: Schema.Element?
        let isSelectedState: Schema.Variable?
    }
}

extension Schema.Localizer {
    func planButton(
        _ value: Schema.Button,
        _ properties: Schema.Element.Properties?,
        in workStack: inout [WorkItem]
    ) throws {
        workStack.append(.buildButton(value, properties))
        if let sel = value.selectedState {
            workStack.append(.planElement(sel))
        }
        workStack.append(.planElement(value.normalState))
    }

    func buildButton(
        _ from: Schema.Button,
        _ properties: Schema.Element.Properties?,
        in resultStack: inout [VC.Element]
    ) {
        let selectedState: VC.Element? = from.selectedState != nil ? resultStack.removeLast() : nil
        let normalState = resultStack.removeLast()
        resultStack.append(.button(
            .init(
                actions: from.actions,
                normalState: normalState,
                selectedState: selectedState,
                isSelectedState: from.isSelectedState
            ),
            properties?.value
        ))
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
                selectedState: container.decodeIfPresent(Schema.Element.self, forKey: .selectedState, configuration: configuration),
                isSelectedState: container.decodeIfPresent(Schema.Variable.self, forKey: .isSelectedState)
            )
            return
        }

        let isSelectedState: Schema.Variable? = switch try container.decodeIfPresent(
            Schema.LegacyStateCondition.self,
            forKey: .legacySelectedCondition
        ) {
        case .selectedProduct(let productId, let groupId):
            .init(
                path: ["Legacy", "productGroup", groupId],
                setter: nil,
                scope: .global,
                converter: .isEqual(.string(productId), falseValue: nil)
            )
        case .selectedSection(let sectionId, let index):
            .init(
                path: ["Legacy", "sections", sectionId],
                setter: nil,
                scope: .global,
                converter: .isEqual(.int32(index), falseValue: nil)
            )
        default:
            nil
        }

        try self.init(
            actions: container.decodeActions(forKey: .actions),
            normalState: container.decode(Schema.Element.self, forKey: .normalState, configuration: configuration),
            selectedState: container.decodeIfPresent(Schema.Element.self, forKey: .selectedState, configuration: configuration),
            isSelectedState: isSelectedState
        )
    }
}
