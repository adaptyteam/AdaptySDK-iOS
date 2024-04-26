//
//  Text+RichText.swift
//
//
//  Created by Aleksey Goncharov on 20.3.24..
//

import Adapty
import UIKit

extension AdaptyUI.RichText.Item {
    var uiFont: UIFont? {
        switch self {
        case let .text(_, attr), let .tag(_, attr): attr.uiFont
        default: nil
        }
    }
}

extension Array where Element == AdaptyUI.RichText.Item {
    func closestItemFont(at index: Int) -> UIFont? {
        if let prevItemFont = self[safe: index - 1]?.uiFont { return prevItemFont }
        if let nextItemFont = self[safe: index + 1]?.uiFont { return nextItemFont }
        if let prevItemRecursiveFont = closestItemFont(at: index - 1) { return prevItemRecursiveFont }
        if let nextItemRecursiveFont = closestItemFont(at: index + 1) { return nextItemRecursiveFont }
        return nil
    }
}

extension AdaptyUI.RichText {
    func attributedString(
        paragraph: AdaptyUI.RichText.ParagraphStyle = .init(),
        kern: CGFloat? = nil,
        tagConverter: AdaptyUI.CustomTagConverter?,
        productTagConverter: AdaptyUI.ProductTagConverter? = nil
    ) -> NSAttributedString {
        guard !isEmpty else { return NSAttributedString() }

        let result = NSMutableAttributedString(string: "")
        var paragraphStyle: NSParagraphStyle?

        for i in 0 ..< items.count {
            let item = items[i]

            switch item {
            case let .text(value, attr):
                result.append(.fromText(value,
                                        attributes: attr,
                                        paragraphStyle: paragraphStyle))
            case let .tag(value, attr):
                let replacementValue = tagConverter?(value) ?? value
                // TODO: replace tag
                result.append(.fromText(replacementValue,
                                        attributes: attr,
                                        paragraphStyle: paragraphStyle))
            case let .paragraph(attr):
                if result.length > 0 {
                    result.append(.newLine(paragraphStyle: paragraphStyle))
                }

                paragraphStyle = attr.paragraphStyle

                if let bullet = attr.bullet {
                    result.append(.bullet(bullet,
                                          bulletSpace: attr.bulletSpace,
                                          paragraphStyle: paragraphStyle))
                }
            case let .image(value, attr):
                result.append(
                    .fromImage(value,
                               attributes: attr,
                               paragraphStyle: paragraphStyle).0
                )
            }
        }

        return result
    }
}

extension String {
    func calculatedWidth(_ attributes: AdaptyUI.RichText.TextAttributes?) -> CGFloat {
        let str = self // Compiler Bug
        return str.size(withAttributes: [
            NSAttributedString.Key.foregroundColor: attributes?.uiColor ?? .darkText,
            NSAttributedString.Key.font: attributes?.uiFont ?? .systemFont(ofSize: 15),
        ]).width
    }
}

extension NSAttributedString {
    static func newLine(paragraphStyle: NSParagraphStyle?) -> NSAttributedString {
        NSMutableAttributedString(
            string: "\n",
            attributes: [
                .paragraphStyle: paragraphStyle ?? NSParagraphStyle(),
            ]
        )
    }

    static func bullet(
        _ bullet: AdaptyUI.RichText.Bullet,
        bulletSpace: Double?,
        paragraphStyle: NSParagraphStyle?
    ) -> NSAttributedString {
        let result = NSMutableAttributedString()
        let reservedSpace: CGFloat

        switch bullet {
        case let .text(value, attr):
            result.append(
                .fromText(value,
                          attributes: attr,
                          paragraphStyle: paragraphStyle)
            )

            reservedSpace = value.calculatedWidth(attr)
        case let .image(value, attr):
            let (string, attachmentSize) = NSAttributedString.fromImage(
                value,
                attributes: attr,
                paragraphStyle: paragraphStyle
            )

            result.append(string)
            reservedSpace = attachmentSize.width
        }

        if let bulletSpace, bulletSpace > 0 {
            let additionalSpace = bulletSpace - reservedSpace

            let padding = NSTextAttachment()
            padding.bounds = CGRect(x: 0, y: 0, width: additionalSpace, height: 0)
            result.append(NSAttributedString(attachment: padding))
        }

        // TODO: consider bulletSpace
        return result
    }

    static func fromText(
        _ value: String,
        attributes: AdaptyUI.RichText.TextAttributes?,
        paragraphStyle: NSParagraphStyle?
    ) -> NSAttributedString {
        let foregroundColor = attributes?.uiColor ?? .darkText

        let result = NSMutableAttributedString(
            string: value,
            attributes: [
                .foregroundColor: foregroundColor,
                .font: attributes?.uiFont ?? .systemFont(ofSize: 15.0), // TODO: move to constant
            ]
        )

        result.addAttributes(
            paragraphStyle: paragraphStyle,
            background: attributes?.background,
            strike: attributes?.strike,
            underline: attributes?.underline
        )

        return result
    }

    static func fromImage(
        _ value: AdaptyUI.ImageData,
        attributes: AdaptyUI.RichText.TextAttributes?,
        paragraphStyle: NSParagraphStyle?
    ) -> (NSAttributedString, CGSize) {
        guard let (attachment, attachmentSize) = value.formAttachment(attributes: attributes) else {
            return (NSAttributedString(string: ""), .zero)
        }

        let result = NSMutableAttributedString()
        result.append(NSAttributedString(attachment: attachment))

        result.addAttributes(
            paragraphStyle: paragraphStyle,
            background: attributes?.background,
            strike: attributes?.strike,
            underline: attributes?.underline
        )

        return (result, attachmentSize)
    }
}

extension NSMutableAttributedString {
    func addAttributes(
        paragraphStyle: NSParagraphStyle?,
        background: AdaptyUI.Filling?,
        strike: Bool?,
        underline: Bool?
    ) {
        if let paragraphStyle {
            addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: length))
        }

        if let background = background?.asColor {
            addAttribute(.backgroundColor, value: background.uiColor, range: NSRange(location: 0, length: length))
        }

        if let strike, strike {
            addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: length))
        }

        if let underline, underline {
            addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: length))
        }
    }
}

extension AdaptyUI.ImageData {
    func formAttachment(
        attributes: AdaptyUI.RichText.TextAttributes?
    ) -> (NSTextAttachment, CGSize)? {
        guard case let .raster(data) = self, var image = UIImage(data: data) else {
            return nil
        }

        // TODO: discuss optional tint
        if let tintColor = attributes?.color.asColor?.uiColor {
            image = image
                .withRenderingMode(.alwaysOriginal)
                .withTintColor(tintColor, renderingMode: .alwaysOriginal)
        }

        let font = attributes?.uiFont ?? .systemFont(ofSize: 15.0)
        let height = font.capHeight
        let width = height / image.size.height * image.size.width

        let imageAttachment = NSTextAttachment()
        imageAttachment.image = image
        imageAttachment.bounds = .init(x: 0, y: 0, width: width, height: height)
        return (
            imageAttachment,
            CGSize(width: width, height: height)
        )
    }
}

extension AdaptyUI.RichText.ParagraphAttributes {
    var paragraphStyle: NSParagraphStyle {
        let result = NSMutableParagraphStyle()
        result.firstLineHeadIndent = firstIndent
        result.headIndent = indent
        result.alignment = horizontalAlign.textAlignment
        return result
    }
}

extension AdaptyUI.HorizontalAlignment {
    var textAlignment: NSTextAlignment {
        switch self {
        case .left: return .natural
        case .center: return .center
        case .right: return .right
        case .fill: return .center // TODO: inspect
        }
    }
}
