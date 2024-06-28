//
//  VC.Toggle.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 28.03.2024
//
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    struct Toggle {
        let onActions: [AdaptyUI.ViewConfiguration.Action]
        let offActions: [AdaptyUI.ViewConfiguration.Action]
        let onCondition: AdaptyUI.StateCondition
        let colorAssetId: String?
    }
}

extension AdaptyUI.ViewConfiguration.Localizer {
    func toggle(_ from: AdaptyUI.ViewConfiguration.Toggle) throws -> AdaptyUI.Toggle {
        try .init(
            onActions: from.onActions.map(action),
            offActions: from.offActions.map(action),
            onCondition: from.onCondition,
            color: from.colorAssetId.flatMap { try? color($0) }
        )
    }
}

extension AdaptyUI.ViewConfiguration.Toggle: Decodable {
    enum CodingKeys: String, CodingKey {
        case sectionId = "section_id"
        case onIndex = "on_index"
        case offIndex = "off_index"

        case onActions = "on_actions"
        case offActions = "off_actions"
        case onCondition = "on_condition"
        case colorAssetId = "color"
    }

    init(from decoder: any Decoder) throws {
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
            if let action = try? container.decodeIfPresent(AdaptyUI.ViewConfiguration.Action.self, forKey: .onActions) {
                [action]
            } else {
                try container.decodeIfPresent([AdaptyUI.ViewConfiguration.Action].self, forKey: .onActions) ?? []
            }
        let offActions =
            if let action = try? container.decodeIfPresent(AdaptyUI.ViewConfiguration.Action.self, forKey: .offActions) {
                [action]
            } else {
                try container.decodeIfPresent([AdaptyUI.ViewConfiguration.Action].self, forKey: .offActions) ?? []
            }
        try self.init(
            onActions: onActions,
            offActions: offActions,
            onCondition: container.decode(AdaptyUI.StateCondition.self, forKey: .onCondition),
            colorAssetId: colorAssetId
        )
    }
}
