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
            package let txtColor: AdaptyUI.Filling
            package let imgTintColor: AdaptyUI.Filling?
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
    }
}
