//
//  Element.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

package extension AdaptyUIConfiguration {
    enum Element: Sendable {
        case space(Int)
        indirect case stack(AdaptyUIConfiguration.Stack, Properties?)
        case text(AdaptyUIConfiguration.Text, Properties?)
        case image(AdaptyUIConfiguration.Image, Properties?)
        case video(AdaptyUIConfiguration.VideoPlayer, Properties?)
        indirect case button(AdaptyUIConfiguration.Button, Properties?)
        indirect case box(AdaptyUIConfiguration.Box, Properties?)
        indirect case row(AdaptyUIConfiguration.Row, Properties?)
        indirect case column(AdaptyUIConfiguration.Column, Properties?)
        indirect case section(AdaptyUIConfiguration.Section, Properties?)
        case toggle(AdaptyUIConfiguration.Toggle, Properties?)
        case timer(AdaptyUIConfiguration.Timer, Properties?)
        indirect case pager(AdaptyUIConfiguration.Pager, Properties?)

        case unknown(String, Properties?)
    }
}

package extension AdaptyUIConfiguration.Element {
    struct Properties: Sendable, Hashable {
        static let defaultPadding = AdaptyUIConfiguration.EdgeInsets(same: .point(0))
        static let defaultOffset = AdaptyUIConfiguration.Offset.zero
        static let defaultOpacity: Double = 1

        package let decorator: AdaptyUIConfiguration.Decorator?
        package let padding: AdaptyUIConfiguration.EdgeInsets
        package let offset: AdaptyUIConfiguration.Offset

        package let opacity: Double
        package let onAppear: [AdaptyUIConfiguration.Animation]
    }
}

extension AdaptyUIConfiguration.Element: Hashable {
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
package extension AdaptyUIConfiguration.Element.Properties {
    static func create(
        decorator: AdaptyUIConfiguration.Decorator? = nil,
        padding: AdaptyUIConfiguration.EdgeInsets = AdaptyUIConfiguration.Element.Properties.defaultPadding,
        offset: AdaptyUIConfiguration.Offset = AdaptyUIConfiguration.Element.Properties.defaultOffset,
        opacity: Double = AdaptyUIConfiguration.Element.Properties.defaultOpacity,
        onAppear: [AdaptyUIConfiguration.Animation] = []
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
