//
//  Filling.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 30.06.2023
//

import Foundation

package extension AdaptyUI {
    enum Filling: Sendable {
        static let `default` = Filling.color(Color.black)

        case color(AdaptyUI.Color)
        case colorGradient(AdaptyUI.ColorGradient)

        package var asColor: AdaptyUI.Color? {
            switch self {
            case let .color(value): value
            default: nil
            }
        }

        package var asColorGradient: AdaptyUI.ColorGradient? {
            switch self {
            case let .colorGradient(value): value
            default: nil
            }
        }

        package var asBackground: AdaptyUI.Background {
            .filling(self)
        }
    }
}

extension AdaptyUI.Filling: Hashable {
    package func hash(into hasher: inout Hasher) {
        switch self {
        case let .color(value):
            hasher.combine(value)
        case let .colorGradient(value):
            hasher.combine(value)
        }
    }
}

#if DEBUG

    package extension AdaptyUI.Filling {
        static func createColor(value: AdaptyUI.Color) -> Self {
            .color(value)
        }

        static func createGradient(value: AdaptyUI.ColorGradient) -> Self {
            .colorGradient(value)
        }
    }
#endif
