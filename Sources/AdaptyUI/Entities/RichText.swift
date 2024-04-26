//
//  RichText.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension AdaptyUI {
    package struct RichText {
        package let items: [RichText.Item]
        package let fallback: [RichText.Item]?
        package let maxRows: Int?
        package let overflowMode: Set<OverflowMode>

        package var isEmpty: Bool { items.isEmpty }

        package enum Item {
            case text(String, TextAttributes)
            case tag(String, TextAttributes)
            case paragraph(ParagraphAttributes)
            case image(AdaptyUI.ImageData, TextAttributes)
        }

        package enum Bullet {
            case text(String, TextAttributes?)
            case image(AdaptyUI.ImageData, TextAttributes?)
        }

        package struct TextAttributes {
            package let font: AdaptyUI.Font
            package let size: Double
            package let color: AdaptyUI.Filling
            package let background: AdaptyUI.Filling?
            package let strike: Bool
            package let underline: Bool
        }

        package struct ParagraphAttributes {
            package let horizontalAlign: AdaptyUI.HorizontalAlignment
            package let firstIndent: Double
            package let indent: Double
            package let bulletSpace: Double?
            package let bullet: Bullet?
        }

        package enum OverflowMode: String {
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
