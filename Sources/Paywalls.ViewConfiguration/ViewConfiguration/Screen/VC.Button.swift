//
//  VC.Button.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 28.03.2024
//
//

import Foundation

extension AdaptyUICore.ViewConfiguration {
    struct Button: Sendable, Hashable {
        let actions: [AdaptyUICore.ViewConfiguration.Action]
        let normalState: AdaptyUICore.ViewConfiguration.Element
        let selectedState: AdaptyUICore.ViewConfiguration.Element?
        let selectedCondition: AdaptyUICore.StateCondition?
    }
}

extension AdaptyUICore.ViewConfiguration.Localizer {
    func button(_ from: AdaptyUICore.ViewConfiguration.Button) throws -> AdaptyUICore.Button {
        try .init(
            actions: from.actions.map(action),
            normalState: element(from.normalState),
            selectedState: from.selectedState.map(element),
            selectedCondition: from.selectedCondition
        )
    }

    func buttonAction(_ from: AdaptyUICore.ActionAction) throws -> AdaptyUICore.ActionAction {
        guard case let .openUrl(stringId) = from else { return from }
        return .openUrl(urlIfPresent(stringId))
    }
}

extension AdaptyUICore.ViewConfiguration.Button: Decodable {
    enum CodingKeys: String, CodingKey {
        case actions = "action"
        case normalState = "normal"
        case selectedState = "selected"
        case selectedCondition = "selected_condition"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let actions =
            if let action = try? container.decode(AdaptyUICore.ViewConfiguration.Action.self, forKey: .actions) {
                [action]
            } else {
                try container.decode([AdaptyUICore.ViewConfiguration.Action].self, forKey: .actions)
            }
        try self.init(
            actions: actions,
            normalState: container.decode(AdaptyUICore.ViewConfiguration.Element.self, forKey: .normalState),
            selectedState: container.decodeIfPresent(AdaptyUICore.ViewConfiguration.Element.self, forKey: .selectedState),
            selectedCondition: container.decodeIfPresent(AdaptyUICore.StateCondition.self, forKey: .selectedCondition)
        )
    }
}
