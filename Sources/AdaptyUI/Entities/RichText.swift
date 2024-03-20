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
        public let fallback: [RichText.Item]?

        public var isEmpty: Bool { items.isEmpty }

        public enum Item {
            case text(String, TextAttributes?)
            case tag(String, TextAttributes?)
            case paragraph(ParagraphAttributes?)
            case image(AdaptyUI.Image?, ImageInTextAttributes?)
        }

        public struct TextAttributes {
            public let font: AdaptyUI.Font?
            public let size: Double?
            public let color: AdaptyUI.Filling?
            public let background: AdaptyUI.Filling?
            public let strike: Bool?
            public let underline: Bool?
        }

        public struct ParagraphAttributes {
            public let horizontalAlign: AdaptyUI.HorizontalAlign?
            public let firstIndent: Double?
            public let indent: Double?
        }

        public struct ImageInTextAttributes {
            public let size: Double?
            public let tint: AdaptyUI.Filling?
            public let background: AdaptyUI.Filling?
            public let strike: Bool?
            public let underline: Bool?
        }
    }
}

extension [AdaptyUI.RichText.Item] {
    public var asString: String? {
        let string = compactMap {
            switch $0 {
            case let .text(value, _), let .tag(value, _):
                value
            case .paragraph:
                "\n"
            default:
                nil
            }
        }.joined()

        return string.isEmpty ? nil : string
    }
}

extension AdaptyUI.RichText {
    public var asString: String? {
        items.asString
    }

    public var asFallbackString: String? {
        fallback?.asString
    }
}
