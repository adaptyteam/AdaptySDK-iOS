//
//  Schema.Toggle.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension Schema {
    typealias Toggle = VC.Toggle
}

extension Schema.Toggle: DecodableWithConfiguration {
    enum CodingKeys: String, CodingKey {
        case value
        case colorAssetId = "color"

        case legacy1SectionId = "section_id"
        case legacy1OnIndex = "on_index"
        case legacy1OffIndex = "off_index"

        case legacy2OnActions = "on_action"
        case legacy2OffActions = "off_action"
        case legacy2OnCondition = "on_condition"
    }

    package init(from decoder: Decoder, configuration: AdaptyUISchema.DecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        guard configuration.isLegacy else {
            try self.init(
                value: container.decode(Schema.Variable.self, forKey: .value),
                color: container.decodeIfPresent(Schema.AssetReference.self, forKey: .colorAssetId)
            )
            return
        }

        if let sectionId = try container.decodeIfPresent(String.self, forKey: .legacy1SectionId) {
            let onIndex = try container.decodeIfPresent(Int32.self, forKey: .legacy1OnIndex) ?? 0
            let offIndex = try container.decodeIfPresent(Int32.self, forKey: .legacy1OffIndex) ?? -1

            // TODO: selectedCondition
            let onActions: [Schema.Action] = [.init(path: ["Legacy", "switchSection"], params: [
                "sectionId": .string(sectionId),
                "index": .int32(onIndex)
            ], scope: .global)]

            let offActions: [Schema.Action] = [.init(path: ["Legacy", "switchSection"], params: [
                "sectionId": .string(sectionId),
                "index": .int32(offIndex)
            ], scope: .global)]

            let onCondition: Schema.LegacyStateCondition = .selectedSection(id: sectionId, index: onIndex)

            try self.init(
                value: .init(path: ["Legacy", "unreleased"], setter: nil, scope: .global),
                color: container.decodeIfPresent(Schema.AssetReference.self, forKey: .colorAssetId)
            )
            return
        }

        // TODO: selectedCondition

        let onActions = try container.decodeIfPresentActions(forKey: .legacy2OnActions) ?? []
        let offActions = try container.decodeIfPresentActions(forKey: .legacy2OffActions) ?? []

        let value: Schema.Variable = switch try container.decode(
            Schema.LegacyStateCondition.self,
            forKey: .legacy2OnCondition
        ) {
        case .selectedProduct(let productId, let groupId):
            .init(path: ["Legacy", "productGroup", groupId, "_\(Schema.LegacyScripts.legacySafeProductId(productId))"], setter: "", scope: .global)
        case .selectedSection(let sectionId, let index):
            .init(path: ["Legacy", "sections", sectionId, "_\(index)"], setter: "", scope: .global)
        }

        try self.init(
            value: value,
            color: container.decodeIfPresent(Schema.AssetReference.self, forKey: .colorAssetId)
        )
    }
}
