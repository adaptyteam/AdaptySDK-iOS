//
//  Element.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

package extension AdaptyViewConfiguration {
    enum Element: Sendable {
        case space(Int)
        indirect case stack(AdaptyViewConfiguration.Stack, Properties?)
        case text(AdaptyViewConfiguration.Text, Properties?)
        case image(AdaptyViewConfiguration.Image, Properties?)
        case video(AdaptyViewConfiguration.VideoPlayer, Properties?)
        indirect case button(AdaptyViewConfiguration.Button, Properties?)
        indirect case box(AdaptyViewConfiguration.Box, Properties?)
        indirect case row(AdaptyViewConfiguration.Row, Properties?)
        indirect case column(AdaptyViewConfiguration.Column, Properties?)
        indirect case section(AdaptyViewConfiguration.Section, Properties?)
        case toggle(AdaptyViewConfiguration.Toggle, Properties?)
        case timer(AdaptyViewConfiguration.Timer, Properties?)
        indirect case pager(AdaptyViewConfiguration.Pager, Properties?)

        case unknown(String, Properties?)
    }
}

package extension AdaptyViewConfiguration.Element {
    struct Properties: Sendable, Hashable {
        static let defaultPadding = AdaptyViewConfiguration.EdgeInsets(same: .point(0))
        static let defaultOffset = AdaptyViewConfiguration.Offset.zero
        static let defaultOpacity: Double = 1

        package let decorator: AdaptyViewConfiguration.Decorator?
        package let padding: AdaptyViewConfiguration.EdgeInsets
        package let offset: AdaptyViewConfiguration.Offset

        package let opacity: Double
        package let onAppear: [AdaptyViewConfiguration.Animation]
    }
}

extension AdaptyViewConfiguration.Element: Hashable {
    package func hash(into hasher: inout Hasher) {
        switch self {
        case let .space(value):
            hasher.combine(1)
            hasher.combine(value)
        case let .stack(value, properties):
            hasher.combine(2)
            hasher.combine(value)
            hasher.combine(properties)
        case let .text(value, properties):
            hasher.combine(3)
            hasher.combine(value)
            hasher.combine(properties)
        case let .image(value, properties):
            hasher.combine(4)
            hasher.combine(value)
            hasher.combine(properties)
        case let .video(value, properties):
            hasher.combine(value)
            hasher.combine(properties)
        case let .button(value, properties):
            hasher.combine(5)
            hasher.combine(value)
            hasher.combine(properties)
        case let .box(value, properties):
            hasher.combine(6)
            hasher.combine(value)
            hasher.combine(properties)
        case let .row(value, properties):
            hasher.combine(7)
            hasher.combine(value)
            hasher.combine(properties)
        case let .column(value, properties):
            hasher.combine(8)
            hasher.combine(value)
            hasher.combine(properties)
        case let .section(value, properties):
            hasher.combine(9)
            hasher.combine(value)
            hasher.combine(properties)
        case let .toggle(value, properties):
            hasher.combine(10)
            hasher.combine(value)
            hasher.combine(properties)
        case let .timer(value, properties):
            hasher.combine(11)
            hasher.combine(value)
            hasher.combine(properties)
        case let .pager(value, properties):
            hasher.combine(12)
            hasher.combine(value)
            hasher.combine(properties)
        case let .unknown(value, properties):
            hasher.combine(13)
            hasher.combine(value)
            hasher.combine(properties)
        }
    }
}

#if DEBUG
package extension AdaptyViewConfiguration.Element.Properties {
    static func create(
        decorator: AdaptyViewConfiguration.Decorator? = nil,
        padding: AdaptyViewConfiguration.EdgeInsets = AdaptyViewConfiguration.Element.Properties.defaultPadding,
        offset: AdaptyViewConfiguration.Offset = AdaptyViewConfiguration.Element.Properties.defaultOffset,
        opacity: Double = AdaptyViewConfiguration.Element.Properties.defaultOpacity,
        onAppear: [AdaptyViewConfiguration.Animation] = []
    ) -> Self {
        .init(
            decorator: decorator,
            padding: padding,
            offset: offset,
            opacity: opacity,
            onAppear: onAppear
        )
    }
}
#endif
