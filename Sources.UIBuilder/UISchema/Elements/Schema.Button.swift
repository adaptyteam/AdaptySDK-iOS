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
    func button(_ from: Schema.Button) throws -> VC.Button {
        try .init(
            actions: from.actions,
            normalState: element(from.normalState),
            selectedState: from.selectedState.map(element),
            isSelectedState: from.isSelectedState
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
            .init(path: ["Legacy", "productGroup", groupId, "_\(Schema.LegacyScripts.legacySafeProductId(productId))"], setter: nil, scope: .global)
        case .selectedSection(let sectionId, let index):
            .init(path: ["Legacy", "sections", sectionId, "_\(index)"], setter: nil, scope: .global)
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
