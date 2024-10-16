//
//  AdaptyUITextView.swift
//
//
//  Created by Aleksey Goncharov on 2.4.24..
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, *)
struct AdaptyUITextView: View {
    @EnvironmentObject var productsViewModel: AdaptyProductsViewModel
    @EnvironmentObject var customTagResolverViewModel: AdaptyTagResolverViewModel

    private var text: AdaptyUI.Text

    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme

    init(_ text: AdaptyUI.Text) {
        self.text = text
    }

    var body: some View {
        let (richText, productInfo) = text.extract(productsInfoProvider: productsViewModel)

        switch productInfo {
        case .notApplicable:
            richText
                .convertToSwiftUIText(
                    tagResolver: customTagResolverViewModel,
                    productInfo: nil,
                    colorScheme: colorScheme
                )
                .multilineTextAlignment(text.horizontalAlign)
                .lineLimit(text.maxRows)
                .minimumScaleFactor(text.overflowMode.contains(.scale) ? 0.01 : 1.0)
        case .notFound:
            richText
                .convertToSwiftUIText(
                    tagResolver: customTagResolverViewModel,
                    productInfo: nil,
                    colorScheme: colorScheme
                )
                .multilineTextAlignment(text.horizontalAlign)
                .lineLimit(text.maxRows)
                .minimumScaleFactor(text.overflowMode.contains(.scale) ? 0.01 : 1.0)
                .redactedAsPlaceholder(true)
        case let .found(productInfoModel):
            richText
                .convertToSwiftUIText(
                    tagResolver: customTagResolverViewModel,
                    productInfo: productInfoModel,
                    colorScheme: colorScheme
                )
                .multilineTextAlignment(text.horizontalAlign)
                .lineLimit(text.maxRows)
                .minimumScaleFactor(text.overflowMode.contains(.scale) ? 0.01 : 1.0)
        }
    }
}

@available(iOS 15.0, *)
extension AdaptyUI.RichText {
    func convertToSwiftUIText(
        tagResolver: AdaptyTagResolver,
        productInfo: ProductInfoModel?,
        colorScheme: ColorScheme
    ) -> Text {
        items.reduce(Text("")) { partialResult, item in
            switch item {
            case let .text(value, attr):
                return partialResult + Text(
                    AttributedString.createFrom(
                        value: value,
                        attributes: attr
                    )
                )
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

                return partialResult + Text(
                    AttributedString.createFrom(
                        value: tagReplacementResult,
                        attributes: attr
                    )
                )
            case let .image(value, attr):
                guard let uiImage = value?.of(colorScheme).textAttachmentImage(
                    font: attr.uiFont,
                    tint: attr.imgTintColor?.asSolidColor?.uiColor
                ) else {
                    return partialResult
                }

                return partialResult + Text(
                    Image(
                        uiImage: uiImage
                    )
                )
            }
        }
    }
}

@available(iOS 15.0, *)
extension AdaptyUI.ImageData {
    private var uiImage: UIImage? {
        switch self {
        case let .raster(data):
            UIImage(data: data)
        case let .resources(value):
            UIImage(named: value)
        default:
            nil
        }
    }

    func textAttachmentImage(font: UIFont, tint: UIColor?) -> UIImage? {
        guard var image = uiImage else { return nil }

        let size = CGSize(width: image.size.width * font.capHeight / image.size.height,
                          height: font.capHeight)

        image = image.imageWith(newSize: size)

        if let tint {
            image = image
                .withRenderingMode(.alwaysTemplate)
                .withTintColor(tint, renderingMode: .alwaysTemplate)
        }

        return image
    }
}

extension UIImage {
    func imageWith(newSize: CGSize) -> UIImage {
        let image = UIGraphicsImageRenderer(size: newSize).image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }

        return image.withRenderingMode(renderingMode)
    }
}

@available(iOS 15.0, *)
extension AdaptyUI.Text {
    enum ProductInfoContainer {
        case notApplicable
        case notFound
        case found(ProductInfoModel)
    }

    func extract(productsInfoProvider: ProductsInfoProvider) -> (AdaptyUI.RichText, ProductInfoContainer) {
        switch value {
        case let .text(value):
            return (value, .notApplicable)
        case let .productText(value):
            guard let product = productsInfoProvider.productInfo(by: value.adaptyProductId) else {
                return (value.richText(byPaymentMode: .unknown), .notFound)
            }

            return (value.richText(byPaymentMode: product.paymentMode), .found(product))
        case let .selectedProductText(value):
            guard let product = productsInfoProvider.selectedProductInfo(by: value.productGroupId),
                  let adaptyProductId = product.adaptyProduct?.adaptyProductId
            else {
                return (value.richText(), .notFound)
            }

            return (value.richText(adaptyProductId: adaptyProductId, byPaymentMode: product.paymentMode), .found(product))
        }
    }
}

@available(iOS 15.0, *)
extension AttributedString {
    static func createFrom(
        value: String,
        attributes: AdaptyUI.RichText.TextAttributes?
    ) -> AttributedString {
        var result = AttributedString(value)

        result.foregroundColor = attributes?.uiColor ?? .darkText
        result.font = attributes?.uiFont ?? .adaptyDefault

        if let background = attributes?.background?.asSolidColor {
            result.backgroundColor = background.swiftuiColor
        }

        if attributes?.strike ?? false {
            result.strikethroughStyle = .single
        }

        if attributes?.underline ?? false {
            result.underlineStyle = .single
        }

        return result
    }
}

extension UIFont {
    static let adaptyDefault = UIFont.systemFont(ofSize: 15.0)
}

@available(iOS 15.0, *)
extension AdaptyUI.RichText.TextAttributes {
    var uiFont: UIFont { font.uiFont(size: size) }
    var uiColor: UIColor? { txtColor.asSolidColor?.uiColor }
    var backgroundUIColor: UIColor? { background?.asSolidColor?.uiColor }
}

#endif
