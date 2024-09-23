//
//  Box.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

extension AdaptyUI {
    package struct Box: Sendable, Hashable {
        static let defaultHorizontalAlignment: HorizontalAlignment = .center
        static let defaultVerticalAlignment: VerticalAlignment = .center

        package let width: Length?
        package let height: Length?
        package let horizontalAlignment: HorizontalAlignment
        package let verticalAlignment: VerticalAlignment
        package let content: Element?
    }
}

extension AdaptyUI.Box {
    package enum Length: Sendable {
        case fixed(AdaptyUI.Unit)
        case min(AdaptyUI.Unit)
        case shrink(AdaptyUI.Unit)
        case fillMax
    }
}

extension AdaptyUI.Box.Length: Hashable {
    package func hash(into hasher: inout Hasher) {
        switch self {
        case let .fixed(value):
            hasher.combine(1)
            hasher.combine(value)
        case let .min(value):
            hasher.combine(2)
            hasher.combine(value)
        case let .shrink(value):
            hasher.combine(3)
            hasher.combine(value)
        case .fillMax:
            hasher.combine(4)
        }
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
