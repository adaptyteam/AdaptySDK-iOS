//
//  Schema.Toggle.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension Schema {
    struct Toggle: Sendable, Hashable {
        let onActions: [Schema.Action]
        let offActions: [Schema.Action]
        let onCondition: VC.StateCondition
        let colorAssetId: String?
    }
}

extension Schema.Localizer {
    func toggle(_ from: Schema.Toggle) -> VC.Toggle {
        .init(
            onActions: from.onActions.map(action),
            offActions: from.offActions.map(action),
            onCondition: from.onCondition,
            color: from.colorAssetId.flatMap { try? color($0) }
        )
    }
}

extension Schema.Toggle: Decodable {
    enum CodingKeys: String, CodingKey {
        case sectionId = "section_id"
        case onIndex = "on_index"
        case offIndex = "off_index"

        case onActions = "on_action"
        case offActions = "off_action"
        case onCondition = "on_condition"
        case colorAssetId = "color"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let colorAssetId = try container.decodeIfPresent(String.self, forKey: .colorAssetId)

        if let sectionId = try container.decodeIfPresent(String.self, forKey: .sectionId) {
            let onIndex = try container.decodeIfPresent(Int.self, forKey: .onIndex) ?? 0
            let offIndex = try container.decodeIfPresent(Int.self, forKey: .offIndex) ?? -1

            self.init(
                onActions: [.action(.switchSection(id: sectionId, index: onIndex))],
                offActions: [.action(.switchSection(id: sectionId, index: offIndex))],
                onCondition: .selectedSection(id: sectionId, index: onIndex),
                colorAssetId: colorAssetId
            )
            return
        }

        let onActions =
            if let action = try? container.decodeIfPresent(Schema.Action.self, forKey: .onActions) {
                [action]
            } else {
                try container.decodeIfPresent([Schema.Action].self, forKey: .onActions) ?? []
            }
        let offActions =
            if let action = try? container.decodeIfPresent(Schema.Action.self, forKey: .offActions) {
                [action]
            } else {
                try container.decodeIfPresent([Schema.Action].self, forKey: .offActions) ?? []
            }
        try self.init(
            onActions: onActions,
            offActions: offActions,
            onCondition: container.decode(VC.StateCondition.self, forKey: .onCondition),
            colorAssetId: colorAssetId
        )
    }
}
