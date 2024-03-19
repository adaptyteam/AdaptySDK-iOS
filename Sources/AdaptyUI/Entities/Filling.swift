//
//  Filling.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.06.2023
//

import Foundation

extension AdaptyUI {
    public enum Filling {
        case color(AdaptyUI.Color)
        case colorGradient(AdaptyUI.ColorGradient)
        case image(AdaptyUI.Image)

        public var asColor: AdaptyUI.Color? {
            switch self {
            case let .color(value): value
            default: nil
            }
        }

        public var asColorGradient: AdaptyUI.ColorGradient? {
            switch self {
            case let .colorGradient(value): value
            default: nil
            }
        }

        public var asImage: AdaptyUI.Image? {
            switch self {
            case let .image(value): value
            default: nil
            }
        }
    }
}
