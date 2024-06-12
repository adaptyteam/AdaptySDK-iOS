//
//  Text+RichText.swift
//
//
//  Created by Aleksey Goncharov on 20.3.24..
//

#if canImport(UIKit)

import Adapty
import UIKit

// TODO: move out
extension Collection where Indices.Iterator.Element == Index {
    subscript(safe index: Index) -> Iterator.Element? {
        (startIndex <= index && index < endIndex) ? self[index] : nil
    }
}

@available(iOS 15.0, *)
extension AdaptyUI.RichText.Item {
    var uiFont: UIFont? {
        switch self {
        case let .text(_, attr), let .tag(_, attr): attr.uiFont
        default: nil
        }
    }
}

@available(iOS 15.0, *)
extension [AdaptyUI.RichText.Item] {
    func closestItemFont(at index: Int) -> UIFont? {
        if let prevItemFont = self[safe: index - 1]?.uiFont { return prevItemFont }
        if let nextItemFont = self[safe: index + 1]?.uiFont { return nextItemFont }
        if let prevItemRecursiveFont = closestItemFont(at: index - 1) { return prevItemRecursiveFont }
        if let nextItemRecursiveFont = closestItemFont(at: index + 1) { return nextItemRecursiveFont }
        return nil
    }
}

@available(iOS 15.0, *)
extension AdaptyUI.Text {
    func attributedString_legacy(
        paragraph: AdaptyUI.RichText.ParagraphStyle = .init(),
        kern: CGFloat? = nil,
        tagResolver: AdaptyTagResolver,
        productsInfoProvider: ProductsInfoProvider
    ) -> NSAttributedString {
        let richText: AdaptyUI.RichText?
        let productInfo: ProductInfoModel?

        switch value {
        case let .text(value):
            richText = value
            productInfo = nil
        case let .productText(value):
            guard let product = productsInfoProvider.productInfo(by: value.adaptyProductId) else {
                // TODO: inspect, shimmer?
                richText = nil
                productInfo = nil
                break
            }

            richText = value.richText(byPaymentMode: product.paymentMode)
            productInfo = product
        case let .selectedProductText(value):
            guard let product = productsInfoProvider.selectedProductInfo, let adaptyProductId = product.adaptyProduct?.adaptyProductId else {
                richText = value.richText()
                productInfo = nil
                break
            }

            richText = value.richText(adaptyProductId: adaptyProductId, byPaymentMode: product.paymentMode)
            productInfo = product
        }

        guard let richText else { return NSAttributedString() }

        return richText.attributedString_legacy(
            paragraph: paragraph,
            kern: kern,
            tagResolver: tagResolver,
            productInfo: productInfo
        )
    }
}


@available(iOS 15.0, *)
extension AdaptyUI.RichText {
    func attributedString_legacy(
        paragraph _: AdaptyUI.RichText.ParagraphStyle = .init(),
        kern _: CGFloat? = nil,
        tagResolver: AdaptyTagResolver,
        productInfo: ProductInfoModel?
    ) -> NSAttributedString {
        guard !isEmpty else { return NSAttributedString() }

        let result = NSMutableAttributedString(string: "")

        for i in 0 ..< items.count {
            let item = items[i]

            switch item {
            case let .text(value, attr):
                result.append(.fromText(
                    value,
                    attributes: attr
                ))
            case let .tag(value, attr):
                let tagReplacementResult: String

                if let customTagResult = tagResolver.replacement(for: value) {
                    tagReplacementResult = customTagResult
                } else if let productTag = AdaptyUI.ProductTag(rawValue: value),
                          let productTagResult = productInfo?.stringByTag(productTag)
                {
                    switch productTagResult {
                    case .notApplicable:
                        tagReplacementResult = ""
                    case let .value(string):
                        tagReplacementResult = string
                    }

                } else {
                    tagReplacementResult = ""
                }

                result.append(.fromText(
                    tagReplacementResult,
                    attributes: attr
                ))
            case let .image(value, attr):
                result.append(
                    .fromImage(
                        value,
                        attributes: attr
                    ).0
                )
            }
        }

        return result
    }
}

@available(iOS 15.0, *)
extension String {
    func calculatedWidth(_ attributes: AdaptyUI.RichText.TextAttributes?) -> CGFloat {
        let str = self // Compiler Bug
        return str.size(withAttributes: [
            NSAttributedString.Key.foregroundColor: attributes?.uiColor ?? .darkText,
            NSAttributedString.Key.font: attributes?.uiFont ?? .systemFont(ofSize: 15),
        ]).width
    }
}


@available(iOS 15.0, *)
extension NSAttributedString {
    static func newLine(paragraphStyle: NSParagraphStyle?) -> NSAttributedString {
        NSMutableAttributedString(
            string: "\n",
            attributes: [
                .paragraphStyle: paragraphStyle ?? NSParagraphStyle(),
            ]
        )
    }


    static func fromText(
        _ value: String,
        attributes: AdaptyUI.RichText.TextAttributes?
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
            background: attributes?.background,
            strike: attributes?.strike,
            underline: attributes?.underline
        )

        return result
    }

    static func fromImage(
        _ value: AdaptyUI.ImageData,
        attributes: AdaptyUI.RichText.TextAttributes?
    ) -> (NSAttributedString, CGSize) {
        guard let (attachment, attachmentSize) = value.formAttachment(attributes: attributes) else {
            return (NSAttributedString(string: ""), .zero)
        }

        let result = NSMutableAttributedString()
        result.append(NSAttributedString(attachment: attachment))

        result.addAttributes(
            background: attributes?.background,
            strike: attributes?.strike,
            underline: attributes?.underline
        )

        return (result, attachmentSize)
    }
}

@available(iOS 15.0, *)
extension NSMutableAttributedString {
    func addAttributes(
        background: AdaptyUI.Filling?,
        strike: Bool?,
        underline: Bool?
    ) {
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

@available(iOS 15.0, *)
extension AdaptyUI.ImageData {
    func formAttachment(
        attributes: AdaptyUI.RichText.TextAttributes?
    ) -> (NSTextAttachment, CGSize)? {
        guard case let .raster(data) = self, var image = UIImage(data: data) else {
            return nil
        }

        // TODO: discuss optional tint
        if let tintColor = attributes?.imgTintColor?.asColor?.uiColor {
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

@available(iOS 15.0, *)
extension AdaptyUI.HorizontalAlignment {
    var textAlignment: NSTextAlignment {
        switch self {
        case .leading: .natural // TODO: inspect
        case .trailing: .right // TODO: inspect
        case .left: .left
        case .center: .center
        case .right: .right
        case .justified: .center // TODO: inspect
        }
    }
}

#endif
