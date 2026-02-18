//
//  AdaptyUIAssetsResolver.swift
//  AdaptyUIBuilder
//
//  Created by Alexey Goncharov on 1/16/25.
//

#if canImport(UIKit) || canImport(AppKit)

import AVKit
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#endif

public enum AdaptyUICustomImageAsset: Sendable {
    case file(url: URL)
    case remote(url: URL, preview: AdaptyPlatformImage?)
    case platformImage(value: AdaptyPlatformImage)
#if canImport(UIKit)
    case uiImage(value: UIImage)
#endif
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
    case nsImage(value: NSImage)
#endif
}

public enum AdaptyUICustomVideoAsset: Sendable {
    case file(url: URL, preview: AdaptyUICustomImageAsset?)
    case remote(url: URL, preview: AdaptyUICustomImageAsset?)
    case player(item: AVPlayerItem, player: AVQueuePlayer, preview: AdaptyUICustomImageAsset?)
}

public enum AdaptyUICustomColorAsset: Sendable {
    case platformColor(AdaptyPlatformColor)
    case swiftUIColor(Color)
#if canImport(UIKit)
    case uiColor(UIColor)
#endif
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
    case nsColor(NSColor)
#endif
}

public enum AdaptyUICustomGradientAsset: Sendable {
    case linear(gradient: Gradient, startPoint: UnitPoint, endPoint: UnitPoint)
    case angular(gradient: Gradient, center: UnitPoint, angle: Angle = .zero)
    case radial(gradient: Gradient, center: UnitPoint, startRadius: CGFloat, endRadius: CGFloat)
}

public enum AdaptyUICustomAsset {
    case image(AdaptyUICustomImageAsset)
    case video(AdaptyUICustomVideoAsset)
    case color(AdaptyUICustomColorAsset)
    case gradient(AdaptyUICustomGradientAsset)
    case font(AdaptyNativeFont)
    case platformFont(AdaptyPlatformFont)
}

extension AdaptyUICustomAsset: @unchecked Sendable {}

public protocol AdaptyUIAssetsResolver: Sendable {
    func asset(for id: String) -> AdaptyUICustomAsset?
}

extension [String: AdaptyUICustomAsset]: AdaptyUIAssetsResolver {
    public func asset(for id: String) -> AdaptyUICustomAsset? { self[id] }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
package struct AdaptyUIDefaultAssetsResolver: AdaptyUIAssetsResolver {
    package init() {}

    package func asset(for id: String) -> AdaptyUICustomAsset? {
        guard let image = SystemSpecificAbstractionManager.image(named: id) else { return nil }
        return .image(.platformImage(value: image))
    }
}

#endif
