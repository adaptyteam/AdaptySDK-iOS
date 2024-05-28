//
//  BottomSheet.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension AdaptyUI {
    package struct BottomSheet {
        package let content: Element
        package let selectedAdaptyProductId: String?
    }
}

#if DEBUG
    package extension AdaptyUI.BottomSheet {
        static func create(
            content: AdaptyUI.Element,
            selectedAdaptyProductId: String? = nil
        ) -> Self {
            .init(
                content: content,
                selectedAdaptyProductId: selectedAdaptyProductId
            )
        }
    }
#endif
