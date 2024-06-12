////
////  Text+AttributedString.swift
////
////
////  Created by Alexey Goncharov on 29.6.23..
////
//
//#if canImport(UIKit)
//
//import Adapty
//import UIKit
//
//@available(iOS 15.0, *)
//extension AdaptyUI.Text {
//    func attributedString(
//        paragraph: AdaptyUI.RichText.ParagraphStyle = .init(),
//        kern: CGFloat? = nil,
//        tagResolver: AdaptyTagResolver,
//        productsInfoProvider: ProductsInfoProvider
//    ) -> AttributedString {
//        let richText: AdaptyUI.RichText?
//        let productInfo: ProductInfoModel?
//
//        switch value {
//        case let .text(value):
//            richText = value
//            productInfo = nil
//        case let .productText(value):
//            guard let product = productsInfoProvider.productInfo(by: value.adaptyProductId) else {
//                // TODO: inspect, shimmer?
//                richText = nil
//                productInfo = nil
//                break
//            }
//
//            richText = value.richText(byPaymentMode: product.paymentMode)
//            productInfo = product
//        case let .selectedProductText(value):
//            guard let product = productsInfoProvider.selectedProductInfo, let adaptyProductId = product.adaptyProduct?.adaptyProductId else {
//                richText = value.richText()
//                productInfo = nil
//                break
//            }
//
//            richText = value.richText(adaptyProductId: adaptyProductId, byPaymentMode: product.paymentMode)
//            productInfo = product
//        }
//
//        guard let richText else { return AttributedString() }
//
//        return richText.attributedString(
//            paragraph: paragraph,
//            kern: kern,
//            tagResolver: tagResolver,
//            productInfo: productInfo
//        )
//    }
//}
//
//@available(iOS 15.0, *)
//extension AttributedString {
//    var isEmpty: Bool { runs.isEmpty }
//}
//
//@available(iOS 15.0, *)
//extension AdaptyUI.RichText {
//    func attributedString(
//        paragraphStyle: AdaptyUI.RichText.ParagraphStyle = .init(),
//        tagResolver: AdaptyTagResolver,
//        productInfo: ProductInfoModel?
//    ) -> AttributedString {
//        guard !isEmpty else { return AttributedString() }
//
//        var result = AttributedString()
//        var currentParagraph: AdaptyUI.RichText.ParagraphAttributes?
//
//        for i in 0 ..< items.count {
//            let item = items[i]
//
//            switch item {
//            case let .text(value, attr):
//                result.append(AttributedString.fromText(
//                    value,
//                    attributes: attr,
//                    paragraph: currentParagraph
//                ))
//            case let .tag(value, attr):
//                let tagReplacementResult: String
//
//                if let customTagResult = tagResolver.replacement(for: value) {
//                    tagReplacementResult = customTagResult
//                } else if let productTag = AdaptyUI.ProductTag(rawValue: value),
//                          let productTagResult = productInfo?.stringByTag(productTag)
//                {
//                    switch productTagResult {
//                    case .notApplicable:
//                        tagReplacementResult = ""
//                    case let .value(string):
//                        tagReplacementResult = string
//                    }
//
//                } else {
//                    tagReplacementResult = ""
//                }
//
//                result.append(AttributedString.fromText(
//                    tagReplacementResult,
//                    attributes: attr,
//                    paragraph: currentParagraph
//                ))
//            case let .paragraph(attr):
//                if !result.isEmpty {
//                    result.append(AttributedString.newLine(paragraph: currentParagraph))
//                }
//
//                currentParagraph = attr
//
//                if let bullet = attr.bullet {
//                    result.append(AttributedString.bullet(
//                        bullet,
//                        bulletSpace: attr.bulletSpace,
//                        paragraph: currentParagraph
//                    ))
//                }
//            case let .image(value, attr):
//                result.append(
//                    AttributedString.fromImage(
//                        value,
//                        attributes: attr,
//                        paragraph: currentParagraph
//                    ).0
//                )
//            }
//        }
//
//        return result
//    }
//}
//
//@available(iOS 15.0, *)
//extension AttributedString {
//    static func newLine(paragraph: AdaptyUI.RichText.ParagraphAttributes?) -> AttributedString {
//        var result = AttributedString("\n", attributes: <#T##AttributeContainer#>)
////        NSMutableAttributedString(
////            string: "\n",
////            attributes: [
////                .paragraphStyle: paragraphStyle ?? NSParagraphStyle(),
////            ]
////        )
//    }
//
//    static func bullet(
//        _ bullet: AdaptyUI.RichText.Bullet,
//        bulletSpace: Double?,
//        paragraph: AdaptyUI.RichText.ParagraphAttributes?
//    ) -> AttributedString {
//        var result = AttributedString()
//        let reservedSpace: CGFloat
//
//        switch bullet {
//        case let .text(value, attr):
//            result.append(
//                AttributedString.fromText(
//                    value,
//                    attributes: attr,
//                    paragraph: paragraph
//                )
//            )
//
//            reservedSpace = value.calculatedWidth(attr)
//        case let .image(value, attr):
//            let (string, attachmentSize) = AttributedString.fromImage(
//                value,
//                attributes: attr,
//                paragraph: paragraph
//            )
//
//            result.append(string)
//            reservedSpace = attachmentSize.width
//        }
//
//        if let bulletSpace, bulletSpace > 0 {
//            let additionalSpace = bulletSpace - reservedSpace
//
//            let padding = NSTextAttachment()
//            padding.bounds = CGRect(x: 0, y: 0, width: additionalSpace, height: 0)
//            result.append(NSAttributedString(attachment: padding))
//        }
//
//        // TODO: consider bulletSpace
//        return result
//    }
//
//    static func fromImage(
//        _ value: AdaptyUI.ImageData,
//        attributes: AdaptyUI.RichText.TextAttributes?,
//        paragraph: AdaptyUI.RichText.ParagraphAttributes?
//    ) -> (AttributedString, CGSize) {
//        guard let (attachment, attachmentSize) = value.formAttachment(attributes: attributes) else {
//            return (NSAttributedString(string: ""), .zero)
//        }
//
//        let result = NSMutableAttributedString()
//        result.append(NSAttributedString(attachment: attachment))
//
//        result.addAttributes(
//            paragraphStyle: paragraphStyle,
//            background: attributes?.background,
//            strike: attributes?.strike,
//            underline: attributes?.underline
//        )
//
//        return (result, attachmentSize)
//    }
//
//    static func fromText(
//        _ value: String,
//        attributes: AdaptyUI.RichText.TextAttributes?,
//        paragraph: AdaptyUI.RichText.ParagraphAttributes?
//    ) -> AttributedString {
//        AttributedString(value).withAttributes(
//            attributes: attributes,
//            paragraph: paragraph,
//            background: attributes?.background,
//            strike: attributes?.strike,
//            underline: attributes?.underline
//        )
//    }
//}
//
//@available(iOS 15.0, *)
//extension AttributedString {
//    func withAttributes(
//        attributes: AdaptyUI.RichText.TextAttributes?,
//        paragraph: AdaptyUI.RichText.ParagraphAttributes?,
//        background: AdaptyUI.Filling?,
//        strike: Bool?,
//        underline: Bool?
//    ) -> AttributedString {
//        var result = self
//
//        result.foregroundColor = attributes?.uiColor ?? .darkText
//        result.font = attributes?.uiFont ?? .systemFont(ofSize: 15.0) // TODO: move to constant
//
//        if let paragraph {
////            ???
////            package let horizontalAlign: AdaptyUI.HorizontalAlignment
////            package let firstIndent: Double
////            package let indent: Double
////            package let bulletSpace: Double?
////            package let bullet: Bullet?
////            addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: length))
//        }
//
//        if let background = background?.asColor {
//            result.backgroundColor = background.swiftuiColor
//        }
//
//        if let strike, strike {
//            result.strikethroughStyle = .single
//        }
//
//        if let underline, underline {
//            result.underlineStyle = .single
//        }
//
//        return self
//    }
//}
//
//#endif
