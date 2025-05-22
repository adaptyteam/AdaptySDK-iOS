//
//  AdaptyUITextView.swift
//
//
//  Created by Aleksey Goncharov on 2.4.24..
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct AdaptyUITextView: View {
    @EnvironmentObject var productsViewModel: AdaptyProductsViewModel
    @EnvironmentObject var customTagResolverViewModel: AdaptyTagResolverViewModel

    private var text: VC.Text

    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme
    @EnvironmentObject
    private var assetsViewModel: AdaptyAssetsViewModel

    init(_ text: VC.Text) {
        self.text = text
    }

    var body: some View {
        let (richText, productInfo) = text.extract(productsInfoProvider: productsViewModel)

        switch productInfo {
        case .notApplicable:
            richText
                .convertToSwiftUIText(
                    assetsResolver: assetsViewModel.assetsResolver,
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
                    assetsResolver: assetsViewModel.assetsResolver,
                    tagResolver: customTagResolverViewModel,
                    productInfo: nil,
                    colorScheme: colorScheme,
                    placeholder: true
                )
                .multilineTextAlignment(text.horizontalAlign)
                .lineLimit(text.maxRows)
                .minimumScaleFactor(text.overflowMode.contains(.scale) ? 0.01 : 1.0)
                .redacted(reason: .placeholder)
        case let .found(productInfoModel):
            richText
                .convertToSwiftUIText(
                    assetsResolver: assetsViewModel.assetsResolver,
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

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyUI {
    enum RichTextError: Error {
        case tagReplacementNotFound
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
extension Array where Element == AdaptyViewConfiguration.RichText.Item {
    func convertToSwiftUITextThrowingError(
        assetsResolver: AdaptyAssetsResolver,
        tagResolver: AdaptyTagResolver,
        productInfo: ProductInfoModel?,
        colorScheme: ColorScheme
    ) throws -> Text {
        try reduce(Text("")) { partialResult, item in
            switch item {
            case let .text(value, attr):
                return partialResult + Text(
                    AttributedString.createFrom(
                        value: value,
                        attributes: attr,
                        assetsResolver: assetsResolver
                    )
                )
            case let .tag(value, attr):
                let tagReplacementResult: String

                if let customTagResult = tagResolver.replacement(for: value) {
                    tagReplacementResult = customTagResult
                } else if let productTag = VC.ProductTag(rawValue: value),
                          let productTagResult = productInfo?.stringByTag(productTag)
                {
                    switch productTagResult {
                    case .notApplicable:
                        tagReplacementResult = ""
                    case let .value(string):
                        tagReplacementResult = string
                    }

                } else {
                    throw AdaptyUI.RichTextError.tagReplacementNotFound
                }

                return partialResult + Text(
                    AttributedString.createFrom(
                        value: tagReplacementResult,
                        attributes: attr,
                        assetsResolver: assetsResolver
                    )
                )
            case let .image(value, attr):
                guard let uiImage = value?.of(colorScheme).textAttachmentImage(
                    assetsResolver: assetsResolver,
                    font: attr.uiFont(assetsResolver),
                    tint: attr.imageTintColor?.asSolidColor?.uiColor(assetsResolver)
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

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
extension VC.RichText {
    func convertToSwiftUIText(
        assetsResolver: AdaptyAssetsResolver,
        tagResolver: AdaptyTagResolver,
        productInfo: ProductInfoModel?,
        colorScheme: ColorScheme,
        placeholder: Bool = false
    ) -> Text {
        if placeholder {
            let reducedString = items.reduce("") { partialResult, item in
                switch item {
                case let .text(value, _), let .tag(value, _):
                    return partialResult + value
                default:
                    return partialResult
                }
            }
            return Text(reducedString)
        } else {
            let result: Text

            do {
                result = try items.convertToSwiftUITextThrowingError(
                    assetsResolver: assetsResolver,
                    tagResolver: tagResolver,
                    productInfo: productInfo,
                    colorScheme: colorScheme
                )
            } catch {
                if let fallback, let fallbackText = try? fallback.convertToSwiftUITextThrowingError(
                    assetsResolver: assetsResolver,
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

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
extension VC.ImageData {
    private func uiImage(assetsResolver: AdaptyAssetsResolver) -> UIImage? {
        switch self {
        case let .raster(customId, data):
            if let customId {
                assetsResolver.uiImage(for: customId)
            } else {
                UIImage(data: data)
            }
        default:
            nil
        }
    }

    func textAttachmentImage(
        assetsResolver: AdaptyAssetsResolver,
        font: UIFont,
        tint: UIColor?
    ) -> UIImage? {
        guard var image = uiImage(assetsResolver: assetsResolver) else { return nil }

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

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
extension VC.Text {
    enum ProductInfoContainer {
        case notApplicable
        case notFound
        case found(ProductInfoModel)
    }

    func extract(productsInfoProvider: ProductsInfoProvider) -> (VC.RichText, ProductInfoContainer) {
        switch value {
        case let .text(value):
            return (value, .notApplicable)
        case let .productText(value):
            guard let underlying = productsInfoProvider.productInfo(by: value.adaptyProductId) else {
                return (value.richText(byPaymentMode: .unknown), .notFound)
            }

            return (value.richText(byPaymentMode: underlying.paymentMode), .found(underlying))
        case let .selectedProductText(value):
            guard let underlying = productsInfoProvider.selectedProductInfo(by: value.productGroupId),
                  let adaptyProductId = underlying.adaptyProduct?.adaptyProductId
            else {
                return (value.richText(), .notFound)
            }

            return (value.richText(adaptyProductId: adaptyProductId, byPaymentMode: underlying.paymentMode), .found(underlying))
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
extension AttributedString {
    static func createFrom(
        value: String,
        attributes: VC.RichText.TextAttributes?,
        assetsResolver: AdaptyAssetsResolver
    ) -> AttributedString {
        var result = AttributedString(value)

        result.foregroundColor = attributes?.uiColor(assetsResolver) ?? .darkText
        result.font = attributes?.uiFont(assetsResolver) ?? .adaptyDefault

        if let background = attributes?.background?.asSolidColor {
            result.backgroundColor = background.swiftuiColor(assetsResolver)
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

@MainActor
extension UIFont {
    static let adaptyDefault = UIFont.systemFont(ofSize: 15.0)
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
extension VC.RichText.TextAttributes {
    func uiFont(_ assetsResolver: AdaptyAssetsResolver) -> UIFont {
        font.uiFont(size: size, assetsResolver: assetsResolver)
    }

    func uiColor(_ assetsResolver: AdaptyAssetsResolver) -> UIColor? {
        txtColor.asSolidColor?.uiColor(assetsResolver)
    }

    func backgroundUIColor(_ assetsResolver: AdaptyAssetsResolver) -> UIColor? {
        background?.asSolidColor?.uiColor(assetsResolver)
    }
}

#endif
