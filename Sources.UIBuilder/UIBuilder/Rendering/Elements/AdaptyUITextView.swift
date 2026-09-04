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
    private var stateViewModel: AdaptyUIStateViewModel
    @EnvironmentObject
    private var productsViewModel: AdaptyUIProductsViewModel
    @EnvironmentObject
    private var customTagResolverViewModel: AdaptyUITagResolverViewModel

    private var text: VC.Text

    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme
    @Environment(\.adaptyScreenInstance)
    private var screen: VS.ScreenInstance
    @Environment(\.adaptyShowsDebugPlaceholders)
    private var showsDebugPlaceholders: Bool

    init(_ text: VC.Text) {
        self.text = text
    }

    var body: some View {
        let (richText, tagValues, productInfo) = assetsViewModel.resolvedText(
            text.value,
            screen: screen,
            productsInfoProvider: productsViewModel
        )

        let defaultFontAsset = assetsViewModel.cache.cachedAsset(
            text.defaultTextAttributes?.fontAssetId,
            mode: colorScheme.toVCMode,
            screen: screen
        ).asFontAsset

        let lineSpacing: CGFloat? = (text.defaultTextAttributes?.lineHeight ?? defaultFontAsset?.defaultLineHeight).map { lineHeight in
            CGFloat(lineHeight) - (defaultFontAsset?.font.lineHeight ?? 0)
        }

        switch productInfo {
        case .notApplicable:
            richText
                .convertToSwiftUIText(
                    defaultAttributes: text.defaultTextAttributes,
                    assetsCache: assetsViewModel.cache,
                    stateViewModel: stateViewModel,
                    tagValues: tagValues,
                    internalTagResolver: nil,
                    customTagResolver: customTagResolverViewModel,
                    productInfo: nil,
                    colorScheme: colorScheme,
                    screen: screen,
                    showsDebugPlaceholders: showsDebugPlaceholders
                )
                .multilineTextAlignment(text.horizontalAlign)
                .lineLimit(text.maxRows)
                .minimumScaleFactor(text.overflowMode.contains(.scale) ? 0.1 : 1.0)
                .applyLineSpacing(lineSpacing)
        case .notFound:
            richText
                .convertToSwiftUIText(
                    defaultAttributes: text.defaultTextAttributes,
                    assetsCache: assetsViewModel.cache,
                    stateViewModel: stateViewModel,
                    tagValues: tagValues,
                    internalTagResolver: nil,
                    customTagResolver: customTagResolverViewModel,
                    productInfo: nil,
                    colorScheme: colorScheme,
                    screen: screen,
                    placeholder: true,
                    showsDebugPlaceholders: showsDebugPlaceholders
                )
                .multilineTextAlignment(text.horizontalAlign)
                .lineLimit(text.maxRows)
                .minimumScaleFactor(text.overflowMode.contains(.scale) ? 0.1 : 1.0)
                .applyLineSpacing(lineSpacing)
                .redacted(reason: .placeholder)
        case let .found(productInfoModel):
            richText
                .convertToSwiftUIText(
                    defaultAttributes: text.defaultTextAttributes,
                    assetsCache: assetsViewModel.cache,
                    stateViewModel: stateViewModel,
                    tagValues: tagValues,
                    internalTagResolver: nil,
                    customTagResolver: customTagResolverViewModel,
                    productInfo: productInfoModel,
                    colorScheme: colorScheme,
                    screen: screen,
                    showsDebugPlaceholders: showsDebugPlaceholders
                )
                .multilineTextAlignment(text.horizontalAlign)
                .lineLimit(text.maxRows)
                .minimumScaleFactor(text.overflowMode.contains(.scale) ? 0.1 : 1.0)
                .applyLineSpacing(lineSpacing)
        }
    }
}

extension AdaptyUIBuilder {
    enum RichTextError: Error {
        case tagReplacementNotFound
    }
}

/// Resolves a single rich text tag to its replacement string.
///
/// Shared by the `Text` renderer and by the plain string form used to expose
/// element strings to custom elements, so both apply the same resolution order:
/// internal resolver, app tag resolver, tag values of the string reference,
/// product tags.
@MainActor
func richTextTagReplacement(
    tag: String,
    converter: VC.AnyConverter?,
    stateViewModel: AdaptyUIStateViewModel,
    tagValues: [String: AdaptyUIConfiguration.StringReference.TagValue]?,
    internalTagResolver: AdaptyUIInternalTagResolver?,
    customTagResolver: AdaptyUITagResolver,
    productInfo: ProductResolver?,
    screen: VS.ScreenInstance,
    showsDebugPlaceholders: Bool
) throws -> String {
    if let anyValue = internalTagResolver?(tag),
       let convertedValue = converter?.asTagConverter?.toString(anyValue, locale: stateViewModel.viewConfiguration.locale)
    {
        return convertedValue
    }

    if let customTagResult = customTagResolver.replacement(for: tag) {
        return customTagResult
    }

    if let tagValue = tagValues?[tag] {
        return switch tagValue {
        case let .value(value):
            value
        case let .variable(variable):
            stateViewModel.getTagValue(
                variable,
                converter: converter?.asTagConverter,
                defaultValue: showsDebugPlaceholders ? "<var:\(variable.path.joined(separator: "."))}>" : "",
                screen: screen
            )
        }
    }

    if let productTag = TextProductTag(rawValue: tag),
       let productTagResult = productInfo?.value(byTag: productTag)
    {
        return switch productTagResult {
        case .notApplicable: ""
        case let .value(string): string
        }
    }

    guard showsDebugPlaceholders else {
        throw AdaptyUIBuilder.RichTextError.tagReplacementNotFound
    }

    return "<tag:\(tag)>"
}

@MainActor
extension [VC.RichText.Item] {
    /// Whole rich text as one `AttributedString`.
    ///
    /// Mirrors `convertToSwiftUITextThrowingError` for everything except inline
    /// images: SwiftUI `Text` does not render attachments carried by an
    /// `AttributedString` on any iOS version, so images are carried as
    /// `NSTextAttachment` on a `U+FFFC` run. A host rendering into `UILabel` or
    /// `UITextView` draws them; SwiftUI `Text` silently drops them.
    func convertToAttributedStringThrowingError(
        assetsCache: AdaptyUIAssetsCache,
        stateViewModel: AdaptyUIStateViewModel,
        tagValues: [String: AdaptyUIConfiguration.StringReference.TagValue]?,
        internalTagResolver: AdaptyUIInternalTagResolver?,
        customTagResolver: AdaptyUITagResolver,
        productInfo: ProductResolver?,
        colorScheme: ColorScheme,
        screen: VS.ScreenInstance,
        showsDebugPlaceholders: Bool
    ) throws -> AttributedString {
        try reduce(into: AttributedString()) { partialResult, item in
            switch item {
            case .unknown:
                break
            case let .text(value, attr, action):
                partialResult += AttributedString.createFrom(
                    value: value,
                    link: action?.asURL,
                    attributes: attr,
                    assetsCache: assetsCache,
                    colorScheme: colorScheme
                )
            case let .tag(value, attr, converter, action):
                let replacement = try richTextTagReplacement(
                    tag: value,
                    converter: converter,
                    stateViewModel: stateViewModel,
                    tagValues: tagValues,
                    internalTagResolver: internalTagResolver,
                    customTagResolver: customTagResolver,
                    productInfo: productInfo,
                    screen: screen,
                    showsDebugPlaceholders: showsDebugPlaceholders
                )
                partialResult += AttributedString.createFrom(
                    value: replacement,
                    link: action?.asURL,
                    attributes: attr,
                    assetsCache: assetsCache,
                    colorScheme: colorScheme
                )
            case let .image(value, attr):
                guard let run = AttributedString.attachmentRun(
                    asset: value,
                    attributes: attr,
                    assetsCache: assetsCache,
                    colorScheme: colorScheme,
                    screen: screen
                ) else { return }
                partialResult += run
            }
        }
    }
}

@MainActor
extension [VC.RichText.Item] {
    func convertToSwiftUITextThrowingError(
        assetsCache: AdaptyUIAssetsCache,
        stateViewModel: AdaptyUIStateViewModel,
        tagValues: [String: AdaptyUIConfiguration.StringReference.TagValue]?,
        internalTagResolver: AdaptyUIInternalTagResolver?,
        customTagResolver: AdaptyUITagResolver,
        productInfo: ProductResolver?,
        colorScheme: ColorScheme,
        screen: VS.ScreenInstance,
        showsDebugPlaceholders: Bool
    ) throws -> Text {
        try reduce(Text("")) {
            partialResult,
            item in
            switch item {
            case .unknown:
                return partialResult
            case let .text(value, attr, action):
                return partialResult + Text(
                    AttributedString.createFrom(
                        value: value,
                        link: action?.asURL,
                        attributes: attr,
                        assetsCache: assetsCache,
                        colorScheme: colorScheme
                    )
                )
            case let .tag(value, attr, converter, action):
                let tagReplacementResult = try richTextTagReplacement(
                    tag: value,
                    converter: converter,
                    stateViewModel: stateViewModel,
                    tagValues: tagValues,
                    internalTagResolver: internalTagResolver,
                    customTagResolver: customTagResolver,
                    productInfo: productInfo,
                    screen: screen,
                    showsDebugPlaceholders: showsDebugPlaceholders
                )

                return partialResult + Text(
                    AttributedString.createFrom(
                        value: tagReplacementResult,
                        link: action?.asURL,
                        attributes: attr,
                        assetsCache: assetsCache,
                        colorScheme: colorScheme
                    )
                )
            case let .image(value, attr):
                let imageResolvedAsset = assetsCache.cachedAsset(
                    value,
                    mode: colorScheme.toVCMode,
                    screen: screen
                ).asImageAsset

                let fontResolvedAsset = assetsCache.cachedAsset(
                    attr?.fontAssetId,
                    mode: colorScheme.toVCMode
                ).asFontAsset

                let tintResolvedAsset = assetsCache.cachedAsset(
                    attr?.imageTintColor,
                    mode: colorScheme.toVCMode
                ).asColorAsset?.uiColor

                guard let uiImage = imageResolvedAsset?.textAttachmentImage(
                    font: fontResolvedAsset?.font ?? .adaptyDefaultFont
                ) else {
                    return partialResult
                }

                if let tint = tintResolvedAsset {
                    return partialResult + Text(
                        Image(uiImage: uiImage)
                            .renderingMode(.template)
                    ).foregroundColor(Color(tint))
                } else {
                    return partialResult + Text(
                        Image(uiImage: uiImage)
                    )
                }
            }
        }
    }
}

@MainActor
extension VC.RichText {
    /// `AttributedString` form, mirroring `convertToSwiftUIText` including the
    /// fallback. `nil` when neither the items nor the fallback resolve.
    func convertToAttributedString(
        defaultAttributes: VC.TextAttributes?,
        assetsCache: AdaptyUIAssetsCache,
        stateViewModel: AdaptyUIStateViewModel,
        tagValues: [String: AdaptyUIConfiguration.StringReference.TagValue]?,
        internalTagResolver: AdaptyUIInternalTagResolver?,
        customTagResolver: AdaptyUITagResolver,
        productInfo: ProductResolver?,
        colorScheme: ColorScheme,
        screen: VS.ScreenInstance,
        showsDebugPlaceholders: Bool
    ) -> AttributedString? {
        let resolvedAttributes = assetsCache.resolveDataBinding(defaultAttributes, screen)

        func convert(_ items: [Item]) throws -> AttributedString {
            try items
                .apply(defaultAttributes: resolvedAttributes)
                .convertToAttributedStringThrowingError(
                    assetsCache: assetsCache,
                    stateViewModel: stateViewModel,
                    tagValues: tagValues,
                    internalTagResolver: internalTagResolver,
                    customTagResolver: customTagResolver,
                    productInfo: productInfo,
                    colorScheme: colorScheme,
                    screen: screen,
                    showsDebugPlaceholders: showsDebugPlaceholders
                )
        }

        if let result = try? convert(items) { return result }
        guard let fallback else { return nil }
        return try? convert(fallback)
    }
}

@MainActor
extension VC.RichText {
    func convertToSwiftUIText(
        defaultAttributes: VC.TextAttributes?,
        assetsCache: AdaptyUIAssetsCache,
        stateViewModel: AdaptyUIStateViewModel,
        tagValues: [String: AdaptyUIConfiguration.StringReference.TagValue]?,
        internalTagResolver: AdaptyUIInternalTagResolver?,
        customTagResolver: AdaptyUITagResolver,
        productInfo: ProductResolver?,
        colorScheme: ColorScheme,
        screen: VS.ScreenInstance,
        placeholder: Bool = false,
        showsDebugPlaceholders: Bool = false
    ) -> Text {
        if placeholder {
            let reducedString = items.reduce("") { partialResult, item in
                switch item {
                case let .text(value, _, _):
                    partialResult + value
                case let .tag(value, _, _, _):
                    partialResult + value
                default:
                    partialResult
                }
            }
            return Text(reducedString)
        } else {
            let result: Text

            let defaultAttributes = assetsCache.resolveDataBinding(defaultAttributes, screen)

            do {
                result = try items
                    .apply(defaultAttributes: defaultAttributes)
                    .convertToSwiftUITextThrowingError(
                        assetsCache: assetsCache,
                        stateViewModel: stateViewModel,
                        tagValues: tagValues,
                        internalTagResolver: internalTagResolver,
                        customTagResolver: customTagResolver,
                        productInfo: productInfo,
                        colorScheme: colorScheme,
                        screen: screen,
                        showsDebugPlaceholders: showsDebugPlaceholders
                    )
            } catch {
                if let fallback, let fallbackText = try? fallback
                    .apply(defaultAttributes: defaultAttributes)
                    .convertToSwiftUITextThrowingError(
                        assetsCache: assetsCache,
                        stateViewModel: stateViewModel,
                        tagValues: tagValues,
                        internalTagResolver: internalTagResolver,
                        customTagResolver: customTagResolver,
                        productInfo: productInfo,
                        colorScheme: colorScheme,
                        screen: screen,
                        showsDebugPlaceholders: showsDebugPlaceholders
                    )
                {
                    result = fallbackText
                } else {
                    result = Text("")
                }
            }

            return result
        }
    }
}

extension View {
    @ViewBuilder
    func applyLineSpacing(_ lineSpacing: CGFloat?) -> some View {
        if let lineSpacing {
            self.lineSpacing(lineSpacing)
        } else {
            self
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

@MainActor
extension AttributedString {
    static func createFrom(
        value: String,
        link: URL?,
        attributes: VC.RichText.Attributes?,
        assetsCache: AdaptyUIAssetsCache,
        colorScheme: ColorScheme
    ) -> AttributedString {
        let foregroundColorAsset = assetsCache.cachedAsset(
            attributes?.txtColor,
            mode: colorScheme.toVCMode
        ).asColorAsset

        let fontAsset = assetsCache.cachedAsset(
            attributes?.fontAssetId,
            mode: colorScheme.toVCMode
        ).asFontAsset

        var result = AttributedString(value)

        result.foregroundColor = foregroundColorAsset?.uiColor ?? fontAsset?.defaultColor.uiColor ?? .adaptyDefaultTextColor

        let baseFont = fontAsset?.font ?? .adaptyDefaultFont
        let defaultSize = baseFont.pointSize

        if let size = attributes?.size, CGFloat(size) != defaultSize {
            result.font = baseFont.withSize(size)
        } else {
            result.font = baseFont
        }

        if let backgroundColor = assetsCache.cachedAsset(
            attributes?.background,
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

        if let letterSpacing = attributes?.letterSpacing ?? fontAsset?.defaultLetterSpacing {
            result.kern = CGFloat(letterSpacing)
        }

        result.link = link

        return result
    }
}

@MainActor
extension AttributedString {
    /// A single `U+FFFC` run carrying the inline image as an `NSTextAttachment`.
    ///
    /// The image is pre-scaled to the cap height of the surrounding font, as on
    /// the `Text` path, and pre-tinted: `tintColor` does not reach attachments,
    /// so the bitmap has to carry the colour itself.
    static func attachmentRun(
        asset: VC.AssetReference,
        attributes: VC.RichText.Attributes?,
        assetsCache: AdaptyUIAssetsCache,
        colorScheme: ColorScheme,
        screen: VS.ScreenInstance
    ) -> AttributedString? {
        let imageAsset = assetsCache.cachedAsset(
            asset,
            mode: colorScheme.toVCMode,
            screen: screen
        ).asImageAsset

        let fontAsset = assetsCache.cachedAsset(
            attributes?.fontAssetId,
            mode: colorScheme.toVCMode
        ).asFontAsset

        guard var image = imageAsset?.textAttachmentImage(
            font: fontAsset?.font ?? .adaptyDefaultFont
        ) else { return nil }

        if let tint = assetsCache.cachedAsset(
            attributes?.imageTintColor,
            mode: colorScheme.toVCMode
        ).asColorAsset?.uiColor {
            image = image.withTintColor(tint, renderingMode: .alwaysOriginal)
        }

        let attachment = NSTextAttachment()
        attachment.image = image
        attachment.bounds = CGRect(origin: .zero, size: image.size)

        var run = AttributedString("\u{FFFC}")
        run.attachment = attachment
        return run
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
        font: UIFont
    ) -> UIImage? {
        guard let image = uiImage else { return nil }

        let size = CGSize(
            width: image.size.width * font.capHeight / image.size.height,
            height: font.capHeight
        )

        return image.imageWith(newSize: size)
    }
}

#endif
