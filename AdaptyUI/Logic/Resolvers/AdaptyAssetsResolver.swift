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

public enum AdaptyCustomImageAsset {
    case file(url: URL)
    case remote(url: URL, preview: UIImage?)
    case image(value: UIImage)
}

public enum AdaptyCustomVideoAsset {
    case file(url: URL, preview: AdaptyCustomImageAsset?)
    case remote(url: URL, preview: AdaptyCustomImageAsset?)
    case player(item: AVPlayerItem, player: AVQueuePlayer, preview: AdaptyCustomImageAsset?)
}

public enum AdaptyCustomColorAsset {
    case uiColor(UIColor)
    case swiftUIColor(Color)
}

public enum AdaptyCustomGradientAsset {
    case linear(gradient: Gradient, startPoint: UnitPoint, endPoint: UnitPoint)
    case angular(gradient: Gradient, center: UnitPoint, angle: Angle = .zero)
    case radial(gradient: Gradient, center: UnitPoint, startRadius: CGFloat, endRadius: CGFloat)
}

@MainActor
public protocol AdaptyAssetsResolver: Sendable {
    func image(for id: String) -> AdaptyCustomImageAsset?
    func video(for id: String) -> AdaptyCustomVideoAsset?
    func color(for id: String) -> AdaptyCustomColorAsset?
    func gradient(for id: String) -> AdaptyCustomGradientAsset?
    func font(for id: String, size: Double) -> UIFont?
}

@MainActor
package struct AdaptyUIDefaultAssetsResolver: AdaptyAssetsResolver {
    package init() {}

    package func image(for id: String) -> AdaptyCustomImageAsset? {
        guard let image = UIImage(named: id) else { return nil }
        return .image(value: image)
    }

    package func video(for id: String) -> AdaptyCustomVideoAsset? {
        nil
    }

    package func color(for id: String) -> AdaptyCustomColorAsset? {
        if let color = UIColor(named: id) {
            return .uiColor(color)
        } else {
            return nil
        }
    }

    package func gradient(for id: String) -> AdaptyCustomGradientAsset? {
        nil
    }

    package func font(for id: String, size: Double) -> UIFont? {
        if let font = UIFont(name: id, size: size) {
            return font
        } else {
            return nil
        }
    }
}

#endif
