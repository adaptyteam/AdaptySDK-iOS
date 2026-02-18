//
//  AdaptyUITextView.swift
//
//
//  Created by Aleksey Goncharov on 2.4.24..
//


import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct AdaptyUITextView: View {
    @EnvironmentObject var productsViewModel: AdaptyUIProductsViewModel
    @EnvironmentObject var customTagResolverViewModel: AdaptyUITagResolverViewModel

    private var text: VC.Text

    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme
    @EnvironmentObject
    private var assetsViewModel: AdaptyUIAssetsViewModel

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
                .minimumScaleFactor(text.overflowMode.contains(.scale) ? 0.1 : 1.0)
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
                .minimumScaleFactor(text.overflowMode.contains(.scale) ? 0.1 : 1.0)
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
                .minimumScaleFactor(text.overflowMode.contains(.scale) ? 0.1 : 1.0)
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyUIBuilder {
    enum RichTextError: Error {
        case tagReplacementNotFound
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
extension Array where Element == VC.RichText.Item {
    func convertToSwiftUITextThrowingError(
        assetsResolver: AdaptyUIAssetsResolver,
        tagResolver: AdaptyUITagResolver,
        productInfo: ProductResolver?,
        colorScheme: ColorScheme
    ) throws -> Text {
        try reduce(Text("")) { partialResult, item in
            switch item {
            case let .text(value, attr):
                return partialResult + Text(
                    AttributedString.createFrom(
                        value: value,
                        attributes: attr,
                        assetsResolver: assetsResolver,
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
                        assetsResolver: assetsResolver,
                        colorScheme: colorScheme
                    )
                )
            case let .image(value, attr):
                let tintColor: AdaptyPlatformColor? = {
                    guard let tint = attr.imageTintColor?.asSolidColor else { return nil }

                    let resolved = tint.resolve(
                        with: assetsResolver,
                        colorScheme: colorScheme
                    )
                    return SystemSpecificAbstractionManager.platformColor(from: resolved)
                }()

                guard let image = value?.resolve(with: assetsResolver, colorScheme: colorScheme).textAttachmentImage(
                    font: attr.platformFont(assetsResolver),
                    tint: tintColor
                ) else {
                    return partialResult
                }

                return partialResult + Text(
                    SystemSpecificAbstractionManager.swiftUIImage(from: image)
                )
            }
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
extension VC.RichText {
    func convertToSwiftUIText(
        assetsResolver: AdaptyUIAssetsResolver,
        tagResolver: AdaptyUITagResolver,
        productInfo: ProductResolver?,
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
extension VC.ImageData.Resolved {
    private var platformImage: AdaptyPlatformImage? {
        switch self {
        case let .image(image):
            image
        case .remote(_, preview: _):
            nil
        }
    }

    func textAttachmentImage(
        font: AdaptyPlatformFont,
        tint: AdaptyPlatformColor?
    ) -> AdaptyPlatformImage? {
        guard var image = platformImage else { return nil }

        let capHeight = font.native.capHeight
        let size = CGSize(width: image.native.size.width * capHeight / image.native.size.height,
                          height: capHeight)

        image = SystemSpecificAbstractionManager.resizedImage(image, to: size)

        if let tint {
            image = SystemSpecificAbstractionManager.tintedImage(image, with: tint)
        }

        return image
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
extension VC.Text {
    enum ProductInfoContainer {
        case notApplicable
        case notFound
        case found(ProductResolver)
    }

    func extract(productsInfoProvider: ProductsInfoProvider) -> (VC.RichText, ProductInfoContainer) {
        switch value {
        case let .text(value):
            return (value, .notApplicable)
        case let .productText(value):
            guard let underlying = productsInfoProvider.productInfo(by: value.adaptyProductId) else {
                return (value.richText(), .notFound)
            }

            return (
                value.richText(byPaymentMode: underlying.paymentMode),
                .found(underlying)
            )
        case let .selectedProductText(value):
            guard let underlying = productsInfoProvider.selectedProductInfo(by: value.productGroupId)
            else {
                return (value.richText(), .notFound)
            }

            return (
                value.richText(adaptyProductId: underlying.adaptyProductId,
                               byPaymentMode: underlying.paymentMode),
                .found(underlying)
            )
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
extension AttributedString {
    static func createFrom(
        value: String,
        attributes: VC.RichText.TextAttributes?,
        assetsResolver: AdaptyUIAssetsResolver,
        colorScheme: ColorScheme
    ) -> AttributedString {
        var result = AttributedString(value)

        result.foregroundColor = attributes?.txtColor.asSolidColor?.resolve(
            with: assetsResolver,
            colorScheme: colorScheme
        ) ?? .primary

        result.font = SystemSpecificAbstractionManager.swiftUIFont(
            from: attributes?.platformFont(assetsResolver) ?? .adaptyDefault
        )

        if let background = attributes?.background?.asSolidColor {
            result.backgroundColor = background.resolve(
                with: assetsResolver,
                colorScheme: colorScheme
            )
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
extension AdaptyPlatformFont {
    static let adaptyDefault: AdaptyPlatformFont = {
#if canImport(UIKit)
        AdaptyPlatformFont(AdaptyNativeFont.systemFont(ofSize: 15.0))
#elseif canImport(AppKit)
        AdaptyPlatformFont(AdaptyNativeFont.systemFont(ofSize: 15.0, weight: .regular))
#else
        AdaptyPlatformFont(AdaptyNativeFont.systemFont(ofSize: 15.0))
#endif
    }()
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
extension VC.RichText.TextAttributes {
    func platformFont(_ assetsResolver: AdaptyUIAssetsResolver) -> AdaptyPlatformFont {
        font.resolve(with: assetsResolver, withSize: size)
    }
}
