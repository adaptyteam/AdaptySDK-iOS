//
//  AdaptyUIAssetsResolver.swift
//  AdaptyUIBuilder
//
//  Created by Alexey Goncharov on 1/16/25.
//

#if canImport(AVKit)

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

#if canImport(UIKit)
public extension AdaptyUICustomImageAsset {
    @_disfavoredOverload
    static func remote(url: URL, preview: UIImage?) -> AdaptyUICustomImageAsset {
        .remote(url: url, preview: preview.map { AdaptyPlatformImage(nativeImage: $0) })
    }
}
#endif

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
public extension AdaptyUICustomImageAsset {
    @_disfavoredOverload
    static func remote(url: URL, preview: NSImage?) -> AdaptyUICustomImageAsset {
        .remote(url: url, preview: preview.map { AdaptyPlatformImage(nativeImage: $0) })
    }
}
#endif

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

extension AdaptyUICustomAsset {
    var platformResolvedFont: AdaptyPlatformFont? {
        switch self {
        case let .font(value):
            AdaptyPlatformFont(value)
        case let .platformFont(value):
            value
        default:
            nil
        }
    }
}

extension AdaptyUICustomImageAsset {
    var platformResolvedImage: AdaptyPlatformImage? {
        switch self {
        case let .platformImage(value):
            value
#if canImport(UIKit)
        case let .uiImage(value):
            AdaptyPlatformImage(value)
#endif
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
        case let .nsImage(value):
            AdaptyPlatformImage(value)
#endif
        default:
            nil
        }
    }

    var platformResolvedRemote: (url: URL, preview: AdaptyPlatformImage?)? {
        guard case let .remote(url, preview) = self else {
            return nil
        }
        return (url, preview)
    }
}

extension AdaptyUICustomColorAsset {
    var platformResolvedColor: AdaptyPlatformColor? {
        switch self {
        case let .platformColor(color):
            color
#if canImport(UIKit)
        case let .uiColor(color):
            AdaptyPlatformColor(color)
#endif
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
        case let .nsColor(color):
            AdaptyPlatformColor(color)
#endif
        default:
            nil
        }
    }
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
