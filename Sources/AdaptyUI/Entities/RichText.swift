//
//  RichText.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension AdaptyUI {
    public struct RichText {
        public let items: [RichText.Item]
        public let fallback: [RichText.Item]?
        public let maxRows: Int?
        public let overflowMode: Set<OverflowMode>

        public var isEmpty: Bool { items.isEmpty }

        public enum Item {
            case text(String, TextAttributes)
            case tag(String, TextAttributes)
            case paragraph(ParagraphAttributes)
            case image(AdaptyUI.Image?, TextAttributes)
        }

        public enum Bullet {
            case text(String, TextAttributes?)
            case image(AdaptyUI.Image?, TextAttributes?)
        }

        public struct TextAttributes {
            public let font: AdaptyUI.Font
            public let size: Double
            public let color: AdaptyUI.Filling
            public let background: AdaptyUI.Filling?
            public let strike: Bool
            public let underline: Bool
        }

        public struct ParagraphAttributes {
            public let horizontalAlign: AdaptyUI.HorizontalAlignment
            public let firstIndent: Double
            public let indent: Double
            public let bulletSpace: Double?
            public let bullet: Bullet?
        }

        public enum OverflowMode: String {
            static let empty = Set<OverflowMode>()
            case truncate
            case scale
        }
    }
}

extension AdaptyUI.RichText {
    static let empty = AdaptyUI.RichText(items: [], fallback: nil, maxRows: nil, overflowMode: OverflowMode.empty)

    init(items: [Item], fallback: [Item]?) {
        self.init(items: items, fallback: fallback, maxRows: nil, overflowMode: OverflowMode.empty)
    }
}

extension AdaptyUI.RichText.OverflowMode: Decodable {}
