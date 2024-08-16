//
//  VC.Button.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 28.03.2024
//
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    struct Button: Sendable, Hashable {
        let actions: [AdaptyUI.ViewConfiguration.Action]
        let normalState: AdaptyUI.ViewConfiguration.Element
        let selectedState: AdaptyUI.ViewConfiguration.Element?
        let selectedCondition: AdaptyUI.StateCondition?
    }
}

extension AdaptyUI.ViewConfiguration.Localizer {
    func button(_ from: AdaptyUI.ViewConfiguration.Button) throws -> AdaptyUI.Button {
        try .init(
            actions: from.actions.map(action),
            normalState: element(from.normalState),
            selectedState: from.selectedState.map(element),
            selectedCondition: from.selectedCondition
        )
    }

    func buttonAction(_ from: AdaptyUI.ActionAction) throws -> AdaptyUI.ActionAction {
        guard case let .openUrl(stringId) = from else { return from }
        return .openUrl(urlIfPresent(stringId))
    }
}

extension AdaptyUI.ViewConfiguration.Button: Decodable {
    enum CodingKeys: String, CodingKey {
        case actions = "action"
        case normalState = "normal"
        case selectedState = "selected"
        case selectedCondition = "selected_condition"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let actions =
            if let action = try? container.decode(AdaptyUI.ViewConfiguration.Action.self, forKey: .actions) {
                [action]
            } else {
                try container.decode([AdaptyUI.ViewConfiguration.Action].self, forKey: .actions)
            }
        try self.init(
            actions: actions,
            normalState: container.decode(AdaptyUI.ViewConfiguration.Element.self, forKey: .normalState),
            selectedState: container.decodeIfPresent(AdaptyUI.ViewConfiguration.Element.self, forKey: .selectedState),
            selectedCondition: container.decodeIfPresent(AdaptyUI.StateCondition.self, forKey: .selectedCondition)
        )
    }
}
