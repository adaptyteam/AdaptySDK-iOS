//
//  AdaptyUIAssetsResolver.swift
//  AdaptyUIBuilder
//
//  Created by Alexey Goncharov on 1/16/25.
//

#if canImport(UIKit)

import AVKit
import SwiftUI
import UIKit

public enum AdaptyUICustomImageAsset: Sendable {
    case file(url: URL)
    case remote(url: URL, preview: UIImage?)
    case uiImage(value: UIImage)
}

public enum AdaptyUICustomVideoAsset: Sendable {
    case file(url: URL, preview: AdaptyUICustomImageAsset?, resolution: CGSize?)
    case remote(url: URL, preview: AdaptyUICustomImageAsset?, resolution: CGSize?)
    case player(item: AVPlayerItem, player: AVPlayer, preview: AdaptyUICustomImageAsset?, resolution: CGSize?)
}

public enum AdaptyUICustomColorAsset: Sendable {
    case uiColor(UIColor)
    case swiftUIColor(Color)
}

public struct AdaptyUICustomFontAsset: Sendable {
    public let font: UIFont
    public let defaultColor: AdaptyUICustomColorAsset?
    public let defaultLetterSpacing: Double?
    public let defaultLineHeight: Double?

    public init(
        font: UIFont,
        defaultColor: AdaptyUICustomColorAsset? = nil,
        defaultLetterSpacing: Double? = nil,
        defaultLineHeight: Double? = nil
    ) {
        self.font = font
        self.defaultColor = defaultColor
        self.defaultLetterSpacing = defaultLetterSpacing
        self.defaultLineHeight = defaultLineHeight
    }
}

public enum AdaptyUICustomGradientAsset: Sendable {
    case linear(gradient: Gradient, startPoint: UnitPoint, endPoint: UnitPoint)
    case angular(gradient: Gradient, center: UnitPoint, angle: Angle = .zero)
    case radial(gradient: Gradient, center: UnitPoint, startRadius: CGFloat, endRadius: CGFloat)
}

public enum AdaptyUICustomAsset: Sendable {
    case image(AdaptyUICustomImageAsset)
    case video(AdaptyUICustomVideoAsset)
    case color(AdaptyUICustomColorAsset)
    case gradient(AdaptyUICustomGradientAsset)
    case font(AdaptyUICustomFontAsset)
}

public protocol AdaptyUIAssetsResolver: Sendable {
    func asset(for id: String) -> AdaptyUICustomAsset?
}

extension [String: AdaptyUICustomAsset]: AdaptyUIAssetsResolver {
    public func asset(for id: String) -> AdaptyUICustomAsset? { self[id] }
}

package struct AdaptyUIDefaultAssetsResolver: AdaptyUIAssetsResolver {
    package init() {}

    package func asset(for id: String) -> AdaptyUICustomAsset? {
        guard let uiImage = UIImage(named: id) else { return nil }
        return .image(.uiImage(value: uiImage))
    }
}

@MainActor
public protocol AdaptyUIInternalFontsResolver: Sendable {
    func internalFont(for id: String, size: Double) -> UIFont?
}

@MainActor
extension AdaptyUIBuilder {
    static var internalFontsResolver: AdaptyUIInternalFontsResolver?

    public static func setInternalFontsResolver(_ resolver: AdaptyUIInternalFontsResolver?) {
        internalFontsResolver = resolver
    }
}

#endif
