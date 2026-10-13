//
//  AdaptyUIAsset.swift
//  AdaptyUIBuilder
//
//  Created by Alex Goncharov on 04/09/2026.
//

#if canImport(UIKit)

import SwiftUI
import UIKit

/// Asset of the flow as the app reads it.
///
/// This is the reading side of the asset contract: a custom element asks the
/// context for an asset and gets it in this type, whether the configuration
/// declares the asset or the app substitutes it through
/// ``AdaptyUIAssetsResolver``.
///
/// A colour arrives here as a plain `SwiftUI.Color` with no UIKit alternative
/// to switch on. That is what separates this type from ``AdaptyUICustomAsset``,
/// which the app passes its own assets in with and which keeps its UIKit forms.
public enum AdaptyUIAsset: Sendable {
    case image(AdaptyUIImageAsset)
    case video(AdaptyUIVideoAsset)
    case color(Color)
    case gradient(AdaptyUIGradientAsset)
    case font(AdaptyUIFontAsset)
    case data(AdaptyUIDataAsset)
}

/// Images, videos and gradients cross the boundary in the same shape in both
/// directions: none of them carries a UIKit alternative to choose between.
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
}

/// Payload the SDK carries but does not interpret, declared in the
/// configuration as a data asset. Reaching it is the job of a custom element:
/// the format is meaningful to the app, not to the SDK.
public struct AdaptyUIDataAsset: Sendable {
    /// Format declared by the configuration, for example `lottie`.
    public let format: String

    /// Payload carried by the configuration itself.
    public let value: Data?

    /// Location of the payload, when the configuration points at a file.
    /// The SDK does not download it: it does not interpret the format and
    /// therefore cannot decide how the payload should be fetched or cached.
    public let url: URL?

    /// At least one of `value` and `url` is always present.
    ///
    /// Both are optional rather than mutually exclusive so that a configuration
    /// carrying an inline payload alongside a remote one — as an image already
    /// carries a preview alongside its URL — does not require a new type.
    init(format: String, value: Data? = nil, url: URL? = nil) {
        self.format = format
        self.value = value
        self.url = url
    }
}

#endif
