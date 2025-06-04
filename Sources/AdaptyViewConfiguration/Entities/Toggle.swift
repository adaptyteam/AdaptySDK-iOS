//
//  Toggle.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.05.2024
//

import Foundation

extension AdaptyViewConfiguration {
    package struct Toggle: Sendable, Hashable {
        package let onActions: [ActionAction]
        package let offActions: [ActionAction]
        package let onCondition: StateCondition
        package let color: Mode<Color>?
    }
}

#if DEBUG
    package extension AdaptyViewConfiguration.Toggle {
        static func create(
            onActions: [AdaptyViewConfiguration.ActionAction],
            offActions: [AdaptyViewConfiguration.ActionAction],
            onCondition: AdaptyViewConfiguration.StateCondition,
            color: AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.Color>? = nil
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
            color: AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.Color>? = nil
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
