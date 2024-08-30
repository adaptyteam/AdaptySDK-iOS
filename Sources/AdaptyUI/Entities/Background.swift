//
//  Background.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 30.06.2023
//

import Foundation

package extension AdaptyUI {
    enum Background: Sendable {
        static let `default` = Filling.default.asBackground

        case filling(AdaptyUI.Filling)
        case image(AdaptyUI.ImageData)

        package var asColor: AdaptyUI.Color? {
            switch self {
            case let .filling(.color(value)): value
            default: nil
            }
        }

        package var asColorGradient: AdaptyUI.ColorGradient? {
            switch self {
            case let .filling(.colorGradient(value)): value
            default: nil
            }
        }

        package var asFilling: AdaptyUI.Filling? {
            switch self {
            case let .filling(value): value
            default: nil
            }
        }

        package var asImage: AdaptyUI.ImageData? {
            switch self {
            case let .image(value): value
            default: nil
            }
        }
    }
}

extension AdaptyUI.Background: Hashable {
    package func hash(into hasher: inout Hasher) {
        switch self {
        case let .filling(value):
            hasher.combine(value)
        case let .image(value):
            hasher.combine(value)
        }
    }
}

#if DEBUG
    package extension AdaptyUI.Background {
        static func createFilling(value: AdaptyUI.Filling) -> Self {
            .filling(value)
        }
        
        static func createColor(value: AdaptyUI.Color) -> Self {
            .filling(.color(value))
        }

        static func createGradient(value: AdaptyUI.ColorGradient) -> Self {
            .filling(.colorGradient(value))
        }

        static func createImage(value: AdaptyUI.ImageData) -> Self {
            .image(value)
        }
    }
#endif
