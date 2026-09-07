//
//  AdaptyUICustomElementContext.swift
//  AdaptyUIBuilder
//
//  Created by Alex Goncharov on 02/09/2026.
//

#if canImport(UIKit)

import Foundation
import SwiftUI

/// Access from the view of a custom element to the payload of that element and
/// to the flow around it.
///
/// Every channel is optional: a missing identifier yields a missing value, so
/// the app can tell an absent payload from an empty one and substitute its own
/// content. Values are read on every view build and always reflect the current
/// state of the flow.
@MainActor
public struct AdaptyUICustomElementContext {
    // consider adding getSelectedProduct + something
    
    private let element: VC.CustomElement
    private let screen: VS.ScreenInstance
    private let colorScheme: ColorScheme
    private let showsDebugPlaceholders: Bool

    /// Version of the flow state this context was built for. Not exposed: it
    /// exists so that a context built after a state update differs from the
    /// previous one, which is what makes SwiftUI re-evaluate the app view built
    /// around it.
    private let stateRevision: UInt

    private let assetsViewModel: AdaptyUIAssetsViewModel
    private let stateViewModel: AdaptyUIStateViewModel
    private let productsViewModel: AdaptyUIProductsViewModel
    private let tagResolverViewModel: AdaptyUITagResolverViewModel

    init(
        element: VC.CustomElement,
        screen: VS.ScreenInstance,
        colorScheme: ColorScheme,
        showsDebugPlaceholders: Bool,
        stateRevision: UInt,
        assetsViewModel: AdaptyUIAssetsViewModel,
        stateViewModel: AdaptyUIStateViewModel,
        productsViewModel: AdaptyUIProductsViewModel,
        tagResolverViewModel: AdaptyUITagResolverViewModel
    ) {
        self.element = element
        self.screen = screen
        self.colorScheme = colorScheme
        self.showsDebugPlaceholders = showsDebugPlaceholders
        self.stateRevision = stateRevision
        self.assetsViewModel = assetsViewModel
        self.stateViewModel = stateViewModel
        self.productsViewModel = productsViewModel
        self.tagResolverViewModel = tagResolverViewModel
    }

    // MARK: - Assets

    /// Asset declared under `id` in the `assets` of the element, or the one the
    /// app substituted for it through `AdaptyUIAssetsResolver`.
    public func asset(_ id: String) -> AdaptyUIAsset? {
        guard let ref = element.assets?[id] else { return nil }
        return assetsViewModel.cache.asset(
            ref,
            mode: colorScheme.toVCMode,
            screen: screen
        )
    }

    /// View rendering the image declared under `id` in the `assets` of the
    /// element. Uses the media cache of the SDK and shows the preview of a
    /// remote image as a placeholder until the image is available.
    ///
    /// The image is resizable and imposes no aspect of its own: apply
    /// `.scaledToFit()`, `.aspectRatio(contentMode:)` or a frame on top, exactly
    /// as for any SwiftUI image.
    public func imageView(_ id: String) -> (some View)? {
        guard let ref = element.assets?[id] else {
            return AdaptyUIImageView?.none
        }
        return AdaptyUIImageView(
            .unresolvedAsset(.init(asset: ref, aspect: .stretch, tint: nil))
        )
    }

    // MARK: - Strings

    /// Localized string declared under `id` in the `strings` of the element,
    /// with tag values substituted and formatting preserved: colour, font,
    /// background, strikethrough, underline, kerning and links.
    ///
    /// For the plain text alone use `String(value.characters)`.
    ///
    /// - Note: Inline images are carried as `NSTextAttachment` runs. A host
    ///   rendering this into `UILabel` or `UITextView` draws them; SwiftUI
    ///   `Text` drops attachments on every iOS version, so render the string
    ///   with `textView(_:)` when the configuration uses inline images.
    public func attributedString(_ id: String) -> AttributedString? {
        guard let ref = element.strings?[id] else { return nil }

        let (richText, tagValues, productInfo) = assetsViewModel.resolvedText(
            ref,
            screen: screen,
            productsInfoProvider: productsViewModel
        )

        return richText.convertToAttributedString(
            defaultAttributes: nil,
            assetsCache: assetsViewModel.cache,
            stateViewModel: stateViewModel,
            tagValues: tagValues,
            internalTagResolver: nil,
            customTagResolver: tagResolverViewModel,
            productInfo: productInfo.resolver,
            colorScheme: colorScheme,
            screen: screen,
            showsDebugPlaceholders: showsDebugPlaceholders
        )
    }

    /// View rendering the localized string declared under `id` in the `strings`
    /// of the element, keeping its formatting, fonts and locale.
    public func textView(_ id: String) -> (some View)? { // Todo: consider removing
        guard let ref = element.strings?[id] else {
            return AdaptyUITextView?.none
        }
        return AdaptyUITextView(
            .init(
                value: ref,
                horizontalAlign: .leading,
                maxRows: nil,
                overflowMode: [],
                defaultTextAttributes: nil
            )
        )
    }

    // MARK: - Bindings and properties

    /// Returns the current value of the variable for the key passed to `byKey`,
    /// converted to the requested type.
    /// Supported types are Bool, Int32, UInt32, Double, String and arrays of
    /// these types.
    /// Returns nil if the value is missing, cannot be converted or an error occurs.
    /// Errors are written to the log.
    public func variableValue<T>(_: T.Type, byKey id: String) -> T? {
        guard let variable = element.bindings?[id] else { return nil }
        guard let type = T.self as? any JSValueRepresentable.Type else {
            Log.ui.error("custom element \(element.type):\(element.id) binding \(id) read error: unsupported type \(String(reflecting: T.self))")
            return nil
        }

        do {
            return try stateViewModel.stateHolder.state.getValue(
                type,
                variable: variable,
                screenInstance: screen
            ) as? T
        } catch {
            Log.ui.error("custom element \(element.type):\(element.id) binding \(id) read error: \(error)")
            return nil
        }
    }

    /// Element properties as defined in Adapty Flow Builder.
    /// The SDK does not interpret their contents.
    /// Types and values are compatible with JSON. JSON null is represented as `NSNull`.
    public var properties: [String: any Sendable]? { element.properties }

    // MARK: - Messages

    /// Sends a message from this element to the flow.
    ///
    /// - Warning: Message delivery is not implemented yet. This method only logs the call.
    public func send(message: some Encodable) {
        Log.ui.warn(
            "custom element \(element.type):\(element.id) send(message:) is not implemented yet"
        )
    }
}

private extension AdaptyUIAssetsViewModel.ProductInfoContainer {
    var resolver: ProductResolver? {
        guard case let .found(resolver) = self else { return nil }
        return resolver
    }
}

#endif
