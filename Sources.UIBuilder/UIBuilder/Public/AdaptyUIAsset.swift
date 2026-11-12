//
//  AdaptyUIAsset.swift
//  AdaptyUIBuilder
//
//  Created by Alex Goncharov on 04/09/2026.
//

#if canImport(UIKit)

import SwiftUI
import UIKit

/// Asset of the flow, in both directions.
///
/// The app passes its own assets in through ``AdaptyUIAssetsResolver``, and a
/// custom element reads assets back from its context, in this same type.
///
/// A colour is a plain `SwiftUI.Color`; a `UIColor` is passed in as
/// `Color(uiColor:)`.
public enum AdaptyUIAsset: Sendable {
    case image(AdaptyUIImageAsset)
    case video(AdaptyUIVideoAsset)
    case color(Color)
    case gradient(AdaptyUIGradientAsset)
    case font(AdaptyUIFontAsset)
    case data(AdaptyUIDataAsset)
}

@available(*, deprecated, renamed: "AdaptyUIAsset")
public typealias AdaptyUICustomAsset = AdaptyUIAsset

public typealias AdaptyUIImageAsset = AdaptyUICustomImageAsset
public typealias AdaptyUIVideoAsset = AdaptyUICustomVideoAsset
public typealias AdaptyUIGradientAsset = AdaptyUICustomGradientAsset

/// Font of the flow together with the text attributes declared alongside it.
///
/// The attributes are what the configuration sets for text drawn in this font;
/// an element rendering the text itself is free to override any of them.
public struct AdaptyUIFontAsset: Sendable {
    public let font: UIFont
    public let color: Color?
    public let letterSpacing: Double?
    public let lineHeight: Double?

    public init(
        font: UIFont,
        color: Color? = nil,
        letterSpacing: Double? = nil,
        lineHeight: Double? = nil
    ) {
        self.font = font
        self.color = color
        self.letterSpacing = letterSpacing
        self.lineHeight = lineHeight
    }
}

/// Payload the SDK carries but does not interpret. Reaching it is the job of a
/// custom element: the format is meaningful to the app, not to the SDK.
///
/// The SDK never draws a data asset, so substituting one through
/// ``AdaptyUIAssetsResolver`` only changes what custom elements read.
public struct AdaptyUIDataAsset: Sendable {
    /// Format of the payload, for example `lottie`.
    public let format: String

    /// Payload carried by the configuration itself.
    public let value: Data?

    /// Location of the payload, local or remote.
    /// The SDK does not download it: it does not interpret the format and
    /// therefore cannot decide how the payload should be fetched or cached.
    public let url: URL?

    /// At least one of `value` and `url` is always present.
    ///
    /// Both are optional rather than mutually exclusive so that a configuration
    /// carrying an inline payload alongside a remote one — as an image already
    /// carries a preview alongside its URL — does not require a new type.
    public init(format: String, value: Data) {
        self.init(format: format, value: value, url: nil)
    }

    public init(format: String, url: URL) {
        self.init(format: format, value: nil, url: url)
    }

    init(format: String, value: Data?, url: URL?) {
        self.format = format
        self.value = value
        self.url = url
    }
}

#endif
