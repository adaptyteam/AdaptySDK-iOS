//
//  Button.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 28.03.2024
//
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    struct Button {
        let action: AdaptyUI.ButtonAction?
        let isSelected: Bool
        let normalState: AdaptyUI.ViewConfiguration.Element?
        let selectedState: AdaptyUI.ViewConfiguration.Element?
    }
}

extension AdaptyUI.ViewConfiguration.Localizer {
    func button(_ from: AdaptyUI.ViewConfiguration.Button) -> AdaptyUI.Button {
        .init(
            action: from.action.map(buttonAction),
            isSelected: from.isSelected,
            normalState: from.normalState.map(element),
            selectedState: from.selectedState.map(element)
        )
    }

    func buttonAction(_ from: AdaptyUI.ButtonAction) -> AdaptyUI.ButtonAction {
        guard case let .openUrl(stringId) = from else { return from }
        return .openUrl(self.urlIfPresent(stringId))
    }
}

extension AdaptyUI.ViewConfiguration.Button: Decodable {
    enum CodingKeys: String, CodingKey {
        case action
        case isSelected = "is_selected"
        case normalState = "normal"
        case selectedState = "selected"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            action: container.decodeIfPresent(AdaptyUI.ButtonAction.self, forKey: .action),
            isSelected: container.decodeIfPresent(Bool.self, forKey: .isSelected) ?? false,
            normalState: container.decodeIfPresent(AdaptyUI.ViewConfiguration.Element.self, forKey: .normalState),
            selectedState: container.decodeIfPresent(AdaptyUI.ViewConfiguration.Element.self, forKey: .selectedState)
        )
    }
}
