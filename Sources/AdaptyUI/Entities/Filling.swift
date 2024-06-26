//
//  Filling.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 30.06.2023
//

import Foundation

package extension AdaptyUI {
    enum Filling {
        static let `default` = Filling.color(Color.black)

        case color(AdaptyUI.Color)
        case colorGradient(AdaptyUI.ColorGradient)
        case image(AdaptyUI.ImageData)

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

        package var asColorFilling: AdaptyUI.ColorFilling? {
            switch self {
            case let .color(value): .color(value)
            case let .colorGradient(value): .colorGradient(value)
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

    enum ColorFilling {
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

        package var asFilling: AdaptyUI.Filling {
            switch self {
            case let .color(value): .color(value)
            case let .colorGradient(value): .colorGradient(value)
            }
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

        static func createImage(value: AdaptyUI.ImageData) -> Self {
            .image(value)
        }
    }

    package extension AdaptyUI.ColorFilling {
        static func createColor(value: AdaptyUI.Color) -> Self {
            .color(value)
        }

        static func createGradient(value: AdaptyUI.ColorGradient) -> Self {
            .colorGradient(value)
        }
    }
#endif
