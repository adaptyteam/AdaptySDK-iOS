//
//  BottomSheet.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension AdaptyUI {
    package struct BottomSheet: Hashable, Sendable {
        package let content: Element
    }
}

#if DEBUG
    package extension AdaptyUI.BottomSheet {
        static func create(
            content: AdaptyUI.Element
        ) -> Self {
            .init(
                content: content
            )
        }
    }
#endif
