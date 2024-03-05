//
//  CompoundText.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.01.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import Foundation

extension AdaptyUI {
    public struct CompoundText {
        public let items: [Text.Item]
        public let bulletSpace: Double?

        var isEmpty: Bool { items.isEmpty }
    }
}

extension AdaptyUI.Text {
    public struct Image {
        public let src: AdaptyUI.Image?
        public let tint: AdaptyUI.Color?
        public let size: AdaptyUI.Size
    }

    public enum Item {
        case text(AdaptyUI.Text)
        case image(AdaptyUI.Text.Image)
        case textBullet(AdaptyUI.Text)
        case imageBullet(AdaptyUI.Text.Image)
        case newline
        case space(Double)

        public var isBullet: Bool {
            switch self {
            case .imageBullet, .textBullet: return true
            default: return false
            }
        }
    }
}
