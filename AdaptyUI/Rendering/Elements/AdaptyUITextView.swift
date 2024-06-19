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

    init(_ text: AdaptyUI.Text) {
        self.text = text
    }

    var body: some View {
        if let (richText, productInfo) = text.extract(productsInfoProvider: productsViewModel) {
            richText
                .convertToSwiftUIText(
                    tagResolver: customTagResolverViewModel,
                    productInfo: productInfo
                )
                .multilineTextAlignment(text.horizontalAlign)
                .lineLimit(text.maxRows)
                .minimumScaleFactor(text.overflowMode.contains(.scale) ? 0.5 : 1.0)
        } else {
            EmptyView()
        }
    }
}

@available(iOS 15.0, *)
extension AdaptyUI.RichText {
    func convertToSwiftUIText(
        tagResolver: AdaptyTagResolver,
        productInfo: ProductInfoModel?
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
                guard let uiImage = value?.textAttachmentImage(
                    font: attr.uiFont ?? .systemFont(ofSize: 15.0),
                    tint: attr.imgTintColor?.asColor?.uiColor
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
        case let .resorces(value):
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
    func extract(productsInfoProvider: ProductsInfoProvider) -> (AdaptyUI.RichText, ProductInfoModel?)? {
        switch value {
        case let .text(value):
            return (value, nil)
        case let .productText(value):
            guard let product = productsInfoProvider.productInfo(by: value.adaptyProductId) else {
                // TODO: inspect, shimmer?
                return nil
            }

            return (value.richText(byPaymentMode: product.paymentMode), product)
        case let .selectedProductText(value):
            let productGroupId = value.productGroupId // TODO: use selected_product from productGroupId  !!
            guard let product = productsInfoProvider.selectedProductInfo, let adaptyProductId = product.adaptyProduct?.adaptyProductId else {
                return (value.richText(), nil)
            }

            return (value.richText(adaptyProductId: adaptyProductId, byPaymentMode: product.paymentMode), product)
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
        result.font = attributes?.uiFont ?? .systemFont(ofSize: 15.0) // TODO: move to constant

        if let background = attributes?.background?.asColor {
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

extension AdaptyUI.RichText.TextAttributes {
    var uiFont: UIFont { font.uiFont(size: size) }
    var uiColor: UIColor? { txtColor.asColor?.uiColor }
    var backgroundUIColor: UIColor? { background?.asColor?.uiColor }
}

#endif
