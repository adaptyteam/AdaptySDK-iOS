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

        let sectionId = try container.decode(String.self, forKey: .legacy1SectionId)
        let onIndex = try container.decodeIfPresent(Int32.self, forKey: .legacy1OnIndex) ?? 0
        let offIndex = try container.decodeIfPresent(Int32.self, forKey: .legacy1OffIndex) ?? -1

        try self.init(
            value: .init(path: ["Legacy", "sections", sectionId], setter: nil, scope: .global, converter: .isEqual(.int32(onIndex), false: .int32(offIndex))),
            color: container.decodeIfPresent(Schema.AssetReference.self, forKey: .colorAssetId)
        )
    }
}
