//
//  Box.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

extension AdaptyUI {
    package struct Box {
        static let defaultHorizontalAlignment: HorizontalAlignment = .center
        static let defaultVerticalAlignment: VerticalAlignment = .center

        package let width: Length?
        package let height: Length?
        package let horizontalAlignment: HorizontalAlignment
        package let verticalAlignment: VerticalAlignment
        package let content: Element?
    }
}

#if DEBUG
    package extension AdaptyUI.Box {
        static func create(
            width: Length? = nil,
            height: Length? = nil,
            horizontalAlignment: AdaptyUI.HorizontalAlignment = defaultHorizontalAlignment,
            verticalAlignment: AdaptyUI.VerticalAlignment = defaultVerticalAlignment,
            content: AdaptyUI.Element? = nil
        ) -> Self {
            .init(
                width: width,
                height: height,
                horizontalAlignment: horizontalAlignment,
                verticalAlignment: verticalAlignment,
                content: content
            )
        }
    }
#endif

extension AdaptyUI.Box {
    package enum Length {
        case fixed(AdaptyUI.Unit)
        case min(AdaptyUI.Unit)
        case shrink(AdaptyUI.Unit)
        case fillMax
    }
}
