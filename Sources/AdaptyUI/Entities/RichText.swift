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

        var isEmpty: Bool { items.isEmpty }

        public enum Item {
            case text(String, TextAttributes?)
            case tag(String, TextAttributes?)
            case paragraph(ParagraphAttributes?)
            case image(AdaptyUI.Image?, ImageInTextAttributes?)
        }

        public struct TextAttributes {
            let font: AdaptyUI.Font?
            let size: Double?
            let color: AdaptyUI.Filling?
            let background: AdaptyUI.Filling?
            let strike: Bool?
            let underline: Bool?
        }

        public struct ParagraphAttributes {
            let horizontalAlign: AdaptyUI.HorizontalAlign?
            let firstIndent: Double?
            let indent: Double?
        }

        public struct ImageInTextAttributes {
            let size: Double?
            let tint: AdaptyUI.Filling?
            let background: AdaptyUI.Filling?
            let strike: Bool?
            let underline: Bool?
        }
    }
}

extension [AdaptyUI.RichText.Item] {
    var asString: String? {
       let string =  compactMap {
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
    var asString: String? {
        items.asString
    }
    var asFallbackString: String? {
        fallback?.asString
    }
}
