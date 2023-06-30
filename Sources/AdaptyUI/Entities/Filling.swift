//
//  Filling.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.06.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import Foundation

extension AdaptyUI {
    public enum Filling {
        case color(AdaptyUI.Color)
        case colorLinearGradient(AdaptyUI.ColorLinearGradient)
        case image(AdaptyUI.Image)

        public var asColor: AdaptyUI.Color? {
            switch self {
            case let .color(value): return value
            default: return nil
            }
        }

        public var asColorLinearGradient: AdaptyUI.ColorLinearGradient? {
            switch self {
            case let .colorLinearGradient(value): return value
            default: return nil
            }
        }

        public var asImage: AdaptyUI.Image? {
            switch self {
            case let .image(value): return value
            default: return nil
            }
        }
    }
}
