//
//  Box.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

extension AdaptyUICore {
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

extension AdaptyUICore.Box {
    package enum Length: Sendable {
        case fixed(AdaptyUICore.Unit)
        case min(AdaptyUICore.Unit)
        case shrink(AdaptyUICore.Unit)
        case fillMax
    }
}

extension AdaptyUICore.Box.Length: Hashable {
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
    package extension AdaptyUICore.Box {
        static func create(
            width: Length? = nil,
            height: Length? = nil,
            horizontalAlignment: AdaptyUICore.HorizontalAlignment = defaultHorizontalAlignment,
            verticalAlignment: AdaptyUICore.VerticalAlignment = defaultVerticalAlignment,
            content: AdaptyUICore.Element? = nil
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
