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
    func convert(_ assetById: (String?) -> AdaptyUI.ViewConfiguration.Asset?) -> AdaptyUI.Button {
        .init(
            action: action,
            isSelected: isSelected,
            normalState: normalState.map { $0.convert(assetById) },
            selectedState: selectedState.map { $0.convert(assetById) }
        )
    }
}
