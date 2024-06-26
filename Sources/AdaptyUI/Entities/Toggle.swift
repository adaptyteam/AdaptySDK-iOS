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
        package let sectionId: String
        package let onIndex: Int
        package let offIndex: Int
        package let color: AdaptyUI.Color?

        package var onCondition: AdaptyUI.Button.SelectedCondition {
            .selectedSection(id: sectionId, index: onIndex)
        }
    }
}

#if DEBUG
    package extension AdaptyUI.Toggle {
        static func create(
            sectionId: String,
            onIndex: Int = 0,
            offIndex: Int = -1,
            color: AdaptyUI.Color? = nil
        ) -> Self {
            .init(
                sectionId: sectionId,
                onIndex: onIndex,
                offIndex: offIndex,
                color: color
            )
        }
    }
#endif
