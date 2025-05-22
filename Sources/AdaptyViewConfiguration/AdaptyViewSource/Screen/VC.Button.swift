//
//  VC.Button.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension AdaptyViewSource {
    struct Button: Sendable, Hashable {
        let actions: [AdaptyViewSource.Action]
        let normalState: AdaptyViewSource.Element
        let selectedState: AdaptyViewSource.Element?
        let selectedCondition: AdaptyViewConfiguration.StateCondition?
    }
}

extension AdaptyViewSource.Localizer {
    func button(_ from: AdaptyViewSource.Button) throws -> AdaptyViewConfiguration.Button {
        try .init(
            actions: from.actions.map(action),
            normalState: element(from.normalState),
            selectedState: from.selectedState.map(element),
            selectedCondition: from.selectedCondition
        )
    }

    func buttonAction(_ from: AdaptyViewConfiguration.ActionAction) throws -> AdaptyViewConfiguration.ActionAction {
        guard case let .openUrl(stringId) = from else { return from }
        return .openUrl(urlIfPresent(stringId))
    }
}

extension AdaptyViewSource.Button: Decodable {
    enum CodingKeys: String, CodingKey {
        case actions = "action"
        case normalState = "normal"
        case selectedState = "selected"
        case selectedCondition = "selected_condition"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let actions =
            if let action = try? container.decode(AdaptyViewSource.Action.self, forKey: .actions) {
                [action]
            } else {
                try container.decode([AdaptyViewSource.Action].self, forKey: .actions)
            }
        try self.init(
            actions: actions,
            normalState: container.decode(AdaptyViewSource.Element.self, forKey: .normalState),
            selectedState: container.decodeIfPresent(AdaptyViewSource.Element.self, forKey: .selectedState),
            selectedCondition: container.decodeIfPresent(AdaptyViewConfiguration.StateCondition.self, forKey: .selectedCondition)
        )
    }
}
