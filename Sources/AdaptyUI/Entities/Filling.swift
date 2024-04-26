//
//  Filling.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 30.06.2023
//

import Foundation

extension AdaptyUI {
    package enum Filling {
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

        package var asImage: AdaptyUI.ImageData? {
            switch self {
            case let .image(value): value
            default: nil
            }
        }
    }
}
