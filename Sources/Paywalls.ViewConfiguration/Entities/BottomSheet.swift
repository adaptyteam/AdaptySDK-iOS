//
//  BottomSheet.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension AdaptyUICore {
    package struct BottomSheet: Sendable, Hashable {
        package let content: Element
    }
}

#if DEBUG
    package extension AdaptyUICore.BottomSheet {
        static func create(
            content: AdaptyUICore.Element
        ) -> Self {
            .init(
                content: content
            )
        }
    }
#endif
