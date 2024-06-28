//
//  Toggle.swift
//
//
//  Created by Aleksei Valiano on 30.05.2024
//
//

import Foundation

extension AdaptyUI {
    package struct Toggle {
        package let onActions: [Action]
        package let offActions: [Action]
        package let onCondition: StateCondition
        package let color: Color?
    }
}

#if DEBUG
    package extension AdaptyUI.Toggle {
        static func create(
            onActions: [AdaptyUI.Action],
            offActions: [AdaptyUI.Action],
            onCondition: AdaptyUI.StateCondition,
            color: AdaptyUI.Color? = nil
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
            color: AdaptyUI.Color? = nil
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
