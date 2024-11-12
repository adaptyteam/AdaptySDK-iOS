//
//  VC.Toggle.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 28.03.2024
//
//

import Foundation

extension AdaptyUICore.ViewConfiguration {
    struct Toggle: Sendable, Hashable {
        let onActions: [AdaptyUICore.ViewConfiguration.Action]
        let offActions: [AdaptyUICore.ViewConfiguration.Action]
        let onCondition: AdaptyUICore.StateCondition
        let colorAssetId: String?
    }
}

extension AdaptyUICore.ViewConfiguration.Localizer {
    func toggle(_ from: AdaptyUICore.ViewConfiguration.Toggle) throws -> AdaptyUICore.Toggle {
        try .init(
            onActions: from.onActions.map(action),
            offActions: from.offActions.map(action),
            onCondition: from.onCondition,
            color: from.colorAssetId.flatMap { try? color($0) }
        )
    }
}

extension AdaptyUICore.ViewConfiguration.Toggle: Decodable {
    enum CodingKeys: String, CodingKey {
        case sectionId = "section_id"
        case onIndex = "on_index"
        case offIndex = "off_index"

        case onActions = "on_actions"
        case offActions = "off_actions"
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
            if let action = try? container.decodeIfPresent(AdaptyUICore.ViewConfiguration.Action.self, forKey: .onActions) {
                [action]
            } else {
                try container.decodeIfPresent([AdaptyUICore.ViewConfiguration.Action].self, forKey: .onActions) ?? []
            }
        let offActions =
            if let action = try? container.decodeIfPresent(AdaptyUICore.ViewConfiguration.Action.self, forKey: .offActions) {
                [action]
            } else {
                try container.decodeIfPresent([AdaptyUICore.ViewConfiguration.Action].self, forKey: .offActions) ?? []
            }
        try self.init(
            onActions: onActions,
            offActions: offActions,
            onCondition: container.decode(AdaptyUICore.StateCondition.self, forKey: .onCondition),
            colorAssetId: colorAssetId
        )
    }
}
