//
//  RichText.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension AdaptyUI {
    public struct RichText {
        static let defaultHorizontalAlign = AdaptyUI.HorizontalAlign.left

        public let items: [RichText.Item]
        public let bulletSpace: Double?

        var isEmpty: Bool { items.isEmpty }

        public enum Item {
            case text(TextItem)
            case image(ImageItem)
            case textBullet(TextItem)
            case imageBullet(ImageItem)
            case newline
            case space(Double)

            public var isBullet: Bool {
                switch self {
                case .imageBullet, .textBullet: return true
                default: return false
                }
            }
        }

        public struct TextItem {
            public let value: String?
            public let fallback: String?
            public let hasTags: Bool
            public let font: AdaptyUI.Font?
            public let size: Double?
            public let fill: AdaptyUI.Filling?
            public let horizontalAlign: AdaptyUI.HorizontalAlign
        }

        public struct ImageItem {
            public let src: AdaptyUI.Image?
            public let tint: AdaptyUI.Color?
            public let size: AdaptyUI.Size
        }
    }
}
