//
//  VC.Button.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 28.03.2024
//
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    struct Button {
        let actions: [AdaptyUI.ViewConfiguration.ButtonAction]
        let normalState: AdaptyUI.ViewConfiguration.Element
        let selectedState: AdaptyUI.ViewConfiguration.Element?
        let selectedCondition: AdaptyUI.StateCondition?
    }
}

extension AdaptyUI.ViewConfiguration.Localizer {
    func button(_ from: AdaptyUI.ViewConfiguration.Button) throws -> AdaptyUI.Button {
        try .init(
            actions: from.actions.map(buttonAction),
            normalState: element(from.normalState),
            selectedState: from.selectedState.map(element),
            selectedCondition: from.selectedCondition
        )
    }

    func buttonAction(_ from: AdaptyUI.ButtonAction) throws -> AdaptyUI.ButtonAction {
        guard case let .openUrl(stringId) = from else { return from }
        return .openUrl(urlIfPresent(stringId))
    }
}

extension AdaptyUI.ViewConfiguration.Button: Decodable {
    enum CodingKeys: String, CodingKey {
        case action
        case normalState = "normal"
        case selectedState = "selected"
        case selectedCondition = "selected_condition"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let actions =
            if let action = try? container.decode(AdaptyUI.ViewConfiguration.ButtonAction.self, forKey: .action) {
                [action]
            } else {
                try container.decode([AdaptyUI.ViewConfiguration.ButtonAction].self, forKey: .action)
            }
        try self.init(
            actions: actions,
            normalState: container.decode(AdaptyUI.ViewConfiguration.Element.self, forKey: .normalState),
            selectedState: container.decodeIfPresent(AdaptyUI.ViewConfiguration.Element.self, forKey: .selectedState),
            selectedCondition: container.decodeIfPresent(AdaptyUI.StateCondition.self, forKey: .selectedCondition)
        )
    }
}
