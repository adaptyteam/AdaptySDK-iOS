//
//  AdaptyUITextView.swift
//
//
//  Created by Aleksey Goncharov on 2.4.24..
//

#if canImport(UIKit)

import SwiftUI

struct AdaptyUITextView: View {
    @EnvironmentObject
    private var assetsViewModel: AdaptyUIAssetsViewModel
    @EnvironmentObject
    private var productsViewModel: AdaptyUIProductsViewModel
    @EnvironmentObject
    private var customTagResolverViewModel: AdaptyUITagResolverViewModel

    private var text: VC.Text

    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme

    init(_ text: VC.Text) {
        self.text = text
    }

    var body: some View {
        let (richText, productInfo) = assetsViewModel.resolvedText(
            text.value,
            defaultAttributes: .init(
                font: nil,
                size: 12,
                txtColor: .color(.white),
                imageTintColor: nil,
                background: nil,
                strike: nil,
                underline: nil
            ) // TODO: x check this
//            defaultAttributes: text.defaultTextAttributes
        )

        switch productInfo {
        case .notApplicable:
            richText
                .convertToSwiftUIText(
                    assetsCache: assetsViewModel.cache,
                    tagResolver: customTagResolverViewModel,
                    productInfo: nil,
                    colorScheme: colorScheme
                )
                .multilineTextAlignment(text.horizontalAlign)
                .lineLimit(text.maxRows)
                .minimumScaleFactor(text.overflowMode.contains(.scale) ? 0.1 : 1.0)
        case .notFound:
            richText
                .convertToSwiftUIText(
                    assetsCache: assetsViewModel.cache,
                    tagResolver: customTagResolverViewModel,
                    productInfo: nil,
                    colorScheme: colorScheme,
                    placeholder: true
                )
                .multilineTextAlignment(text.horizontalAlign)
                .lineLimit(text.maxRows)
                .minimumScaleFactor(text.overflowMode.contains(.scale) ? 0.1 : 1.0)
                .redacted(reason: .placeholder)
        case let .found(productInfoModel):
            richText
                .convertToSwiftUIText(
                    assetsCache: assetsViewModel.cache,
                    tagResolver: customTagResolverViewModel,
                    productInfo: productInfoModel,
                    colorScheme: colorScheme
                )
                .multilineTextAlignment(text.horizontalAlign)
                .lineLimit(text.maxRows)
                .minimumScaleFactor(text.overflowMode.contains(.scale) ? 0.1 : 1.0)
        }
    }
}

extension AdaptyUIBuilder {
    enum RichTextError: Error {
        case tagReplacementNotFound
    }
}

@MainActor
extension [VC.RichText.Item] {
    func convertToSwiftUITextThrowingError(
        assetsCache: AdaptyUIAssetsCache,
        tagResolver: AdaptyUITagResolver,
        productInfo: ProductResolver?,
        colorScheme: ColorScheme
    ) throws -> Text {
        try reduce(Text("")) {
            partialResult,
                item in
            switch item {
            case .unknown:
                return partialResult
            case let .text(value, attr):
                return partialResult + Text(
                    AttributedString.createFrom(
                        value: value,
                        attributes: attr,
                        assetsCache: assetsCache,
                        colorScheme: colorScheme
                    )
                )
            case let .tag(value, attr):
                let tagReplacementResult: String

                if let customTagResult = tagResolver.replacement(for: value) {
                    tagReplacementResult = customTagResult
                } else if let productTag = TextProductTag(rawValue: value),
                          let productTagResult = productInfo?.value(byTag: productTag)
                {
                    switch productTagResult {
                    case .notApplicable:
                        tagReplacementResult = ""
                    case let .value(string):
                        tagReplacementResult = string
                    }

                } else {
                    throw AdaptyUIBuilder.RichTextError.tagReplacementNotFound
                }

                return partialResult + Text(
                    AttributedString.createFrom(
                        value: tagReplacementResult,
                        attributes: attr,
                        assetsCache: assetsCache,
                        colorScheme: colorScheme
                    )
                )
            case let .image(value, attr):
                let imageResolvedAsset = assetsCache.cachedAsset(
                    value,
                    mode: colorScheme.toVCMode
                ).asImageAsset

                let fontResolvedAsset = assetsCache.cachedAsset(
                    attr?.font,
                    mode: colorScheme.toVCMode
                ).asFontAsset

                let tintResolvedAsset = assetsCache.cachedAsset(
                    attr?.imageTintColor,
                    mode: colorScheme.toVCMode
                ).asColorAsset?.uiColor

                guard let uiImage = imageResolvedAsset?.textAttachmentImage(
                    font: fontResolvedAsset ?? .adaptyDefaultFont,
                    tint: tintResolvedAsset
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

@MainActor
extension VC.RichText {
    func convertToSwiftUIText(
        assetsCache: AdaptyUIAssetsCache,
        tagResolver: AdaptyUITagResolver,
        productInfo: ProductResolver?,
        colorScheme: ColorScheme,
        placeholder: Bool = false
    ) -> Text {
        if placeholder {
            let reducedString = items.reduce("") { partialResult, item in
                switch item {
                case let .text(value, _), let .tag(value, _):
                    partialResult + value
                default:
                    partialResult
                }
            }
            return Text(reducedString)
        } else {
            let result: Text

            do {
                result = try items.convertToSwiftUITextThrowingError(
                    assetsCache: assetsCache,
                    tagResolver: tagResolver,
                    productInfo: productInfo,
                    colorScheme: colorScheme
                )
            } catch {
                if let fallback, let fallbackText = try? fallback.convertToSwiftUITextThrowingError(
                    assetsCache: assetsCache,
                    tagResolver: tagResolver,
                    productInfo: productInfo,
                    colorScheme: colorScheme
                ) {
                    result = fallbackText
                } else {
                    result = Text("")
                }
            }

            return result
        }
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

// @MainActor
// extension VC.Text {
//    enum ProductInfoContainer {
//        case notApplicable
//        case notFound
//        case found(ProductResolver)
//    }
//
//    func extract(
//        _productsInfoProvider: ProductsInfoProvider
//    ) -> (VC.RichText, ProductInfoContainer) {
//        switch value {
//        case let .stringId(stringId):
//            return (.empty, .notApplicable) // TODO: implement
//        case let .variable(variableStringId):
//            return (.empty, .notApplicable) // TODO: implement
//        case let .product(.id(productId, sufix)):
//            return (.empty, .notApplicable) // TODO: implement
//        case let .product(.variable(variableProductId, sufix)):
//            return (.empty, .notApplicable) // TODO: implement

//
//        case let .text(value):
//            return (value, .notApplicable)
//        case let .productText(value):
//            guard let underlying = productsInfoProvider.productInfo(by: value.adaptyProductId) else {
//                return (value.richText(), .notFound)
//            }
//
//            return (
//                value.richText(byPaymentMode: underlying.paymentMode),
//                .found(underlying)
//            )
//        case let .selectedProductText(value):
//            guard let underlying = productsInfoProvider.selectedProductInfo(by: value.productGroupId)
//            else {
//                return (value.richText(), .notFound)
//            }
//
//            return (
//                value.richText(adaptyProductId: underlying.adaptyProductId,
//                               byPaymentMode: underlying.paymentMode),
//                .found(underlying)
//            )
//        }
//    }
// }

@MainActor
extension AttributedString {
    static func createFrom(
        value: String,
        attributes: VC.RichText.Attributes?,
        assetsCache: AdaptyUIAssetsCache,
        colorScheme: ColorScheme
    ) -> AttributedString {
        let foregroundColorAsset = assetsCache.cachedAsset(
            attributes?.txtColor,
            mode: colorScheme.toVCMode
        ).asColorAsset

        let fontAsset = assetsCache.cachedAsset(
            attributes?.txtColor,
            mode: colorScheme.toVCMode
        ).asFontAsset

        var result = AttributedString(value)

        result.foregroundColor = foregroundColorAsset?.uiColor ?? .adaptyDefaultTextColor
        result.font = (fontAsset ?? .adaptyDefaultFont)
            .withSize(attributes?.size ?? .adaptyDefaultFontSize)

        if let backgroundColor = assetsCache.cachedAsset(
            attributes?.txtColor,
            mode: colorScheme.toVCMode
        ).asColorAsset?.uiColor {
            result.backgroundColor = backgroundColor
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

extension AdaptyUIResolvedImageAsset {
    private var uiImage: UIImage? {
        switch self {
        case let .image(image):
            image
        case .remote(_, preview: _): // TODO: implement this
            nil
        }
    }

    func textAttachmentImage(
        font: UIFont,
        tint: UIColor?
    ) -> UIImage? {
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

#endif
