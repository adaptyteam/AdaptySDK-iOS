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
    case file(url: URL, preview: AdaptyUICustomImageAsset?)
    case remote(url: URL, preview: AdaptyUICustomImageAsset?)
    case player(item: AVPlayerItem, player: AVQueuePlayer, preview: AdaptyUICustomImageAsset?)
}

public enum AdaptyUICustomColorAsset: Sendable {
    case uiColor(UIColor)
    case swiftUIColor(Color)
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
    case font(UIFont)
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

#endif
