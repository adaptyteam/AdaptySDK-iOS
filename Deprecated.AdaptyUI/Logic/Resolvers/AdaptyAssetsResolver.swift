//
//  AdaptyAssetsResolver.swift
//  Adapty
//
//  Created by Alexey Goncharov on 1/16/25.
//

#if canImport(UIKit)

import Adapty
import AVKit
import SwiftUI
import UIKit

public enum AdaptyCustomImageAsset: Sendable {
    case file(url: URL)
    case remote(url: URL, preview: UIImage?)
    case uiImage(value: UIImage)
}

public enum AdaptyCustomVideoAsset: Sendable {
    case file(url: URL, preview: AdaptyCustomImageAsset?)
    case remote(url: URL, preview: AdaptyCustomImageAsset?)
    case player(item: AVPlayerItem, player: AVQueuePlayer, preview: AdaptyCustomImageAsset?)
}

public enum AdaptyCustomColorAsset: Sendable {
    case uiColor(UIColor)
    case swiftUIColor(Color)
}

public enum AdaptyCustomGradientAsset: Sendable {
    case linear(gradient: Gradient, startPoint: UnitPoint, endPoint: UnitPoint)
    case angular(gradient: Gradient, center: UnitPoint, angle: Angle = .zero)
    case radial(gradient: Gradient, center: UnitPoint, startRadius: CGFloat, endRadius: CGFloat)
}

public enum AdaptyCustomAsset: Sendable {
    case image(AdaptyCustomImageAsset)
    case video(AdaptyCustomVideoAsset)
    case color(AdaptyCustomColorAsset)
    case gradient(AdaptyCustomGradientAsset)
    case font(UIFont)
}

public protocol AdaptyAssetsResolver: Sendable {
    func asset(for id: String) -> AdaptyCustomAsset?
}

extension [String: AdaptyCustomAsset]: AdaptyAssetsResolver {
    public func asset(for id: String) -> AdaptyCustomAsset? { self[id] }
}

package struct AdaptyUIDefaultAssetsResolver: AdaptyAssetsResolver {
    package init() {}

    package func asset(for id: String) -> AdaptyCustomAsset? {
        guard let uiImage = UIImage(named: id) else { return nil }
        return .image(.uiImage(value: uiImage))
    }
}

#endif
