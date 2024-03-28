//
//  Button.swift
//  AdaptySDK
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

extension AdaptyUI.ViewConfiguration.Button {
    func convert(_ localizer: AdaptyUI.ViewConfiguration.Localizer) -> AdaptyUI.Button {
        .init(
            action: action.map { $0.convert(localizer) },
            isSelected: isSelected,
            normalState: normalState.map { $0.convert(localizer) },
            selectedState: selectedState.map { $0.convert(localizer) }
        )
    }
}

extension AdaptyUI.ButtonAction {
    func convert(_ localizer: AdaptyUI.ViewConfiguration.Localizer) -> AdaptyUI.ButtonAction {
        guard case let .openUrl(stringId) = self else { return self }
        return .openUrl(localizer.urlIfPresent(stringId))
    }
}
