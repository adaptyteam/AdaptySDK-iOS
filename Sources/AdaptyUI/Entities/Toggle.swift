//
//  Toggle.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 30.05.2024
//
//

import Foundation

extension AdaptyUI {
    package struct Toggle: Hashable, Sendable {
        package let onActions: [ActionAction]
        package let offActions: [ActionAction]
        package let onCondition: StateCondition
        package let color: Mode<Color>?
    }
}

#if DEBUG
    package extension AdaptyUI.Toggle {
        static func create(
            onActions: [AdaptyUI.ActionAction],
            offActions: [AdaptyUI.ActionAction],
            onCondition: AdaptyUI.StateCondition,
            color: AdaptyUI.Mode<AdaptyUI.Color>? = nil
        ) -> Self {
            .init(
                onActions: onActions,
                offActions: offActions,
                onCondition: onCondition,
                color: color
            )
        }

        static func create(
            sectionId: String,
            onIndex: Int = 0,
            offIndex: Int = -1,
            color: AdaptyUI.Mode<AdaptyUI.Color>? = nil
        ) -> Self {
            .init(
                onActions: [.switchSection(id: sectionId, index: onIndex)],
                offActions: [.switchSection(id: sectionId, index: offIndex)],
                onCondition: .selectedSection(id: sectionId, index: onIndex),
                color: color
            )
        }
    }
#endif
