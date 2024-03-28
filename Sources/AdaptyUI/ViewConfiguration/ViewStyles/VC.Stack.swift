//
//  Stack.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 28.03.2024
//
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    struct Stack {
        let type: AdaptyUI.StackType
        let horizontalAlignment: AdaptyUI.HorizontalAlignment
        let verticalAlignment: AdaptyUI.VerticalAlignment
        let elements: [AdaptyUI.ViewConfiguration.Element]
    }
}

extension AdaptyUI.ViewConfiguration.Stack {
    func convert(_ assetById: (String?) -> AdaptyUI.ViewConfiguration.Asset?) -> AdaptyUI.Stack {
        .init(
            type: type,
            horizontalAlignment: horizontalAlignment,
            verticalAlignment: verticalAlignment,
            elements: elements.map { $0.convert(assetById) }
        )
    }
}
