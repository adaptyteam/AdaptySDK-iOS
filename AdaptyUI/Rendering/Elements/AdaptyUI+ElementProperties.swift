//
//  AdaptyUI+ElementProperties.swift
//
//
//  Created by Aleksey Goncharov on 3.4.24..
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension VC.Point {
    var unitPoint: UnitPoint { UnitPoint(x: x, y: y) }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
extension VC.ColorGradient.Item {
    func gradientStop(_ assetsResolver: AdaptyAssetsResolver) -> Gradient.Stop {
        Gradient.Stop(
            color: color.swiftuiColor(assetsResolver),
            location: p
        )
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
extension VC.Mode<VC.Color> {
    private func resolvedColor(style: UIUserInterfaceStyle) -> VC.Color {
        switch style {
        case .dark:
            return mode(.dark)
        default:
            return mode(.light)
        }
    }

    func swiftuiColor(_ assetsResolver: AdaptyAssetsResolver) -> SwiftUI.Color {
        SwiftUI.Color(uiColor(assetsResolver))
    }

    func uiColor(_ assetsResolver: AdaptyAssetsResolver) -> UIColor {
        UIColor {
            resolvedColor(style: $0.userInterfaceStyle).uiColor(assetsResolver)
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
extension VC.Color {
    func swiftuiColor(_ assetsResolver: AdaptyAssetsResolver) -> SwiftUI.Color {
        guard let customId, let customColor = assetsResolver.color(for: customId) else {
            return Color(
                .sRGB,
                red: red,
                green: green,
                blue: blue,
                opacity: alpha
            )
        }

        return switch customColor {
        case let .uiColor(value):
            SwiftUI.Color(value)
        case let .swiftUIColor(value):
            value
        }
    }

    func uiColor(_ assetsResolver: AdaptyAssetsResolver) -> UIColor {
        guard let customId, let customColor = assetsResolver.color(for: customId) else {
            return UIColor(
                red: red,
                green: green,
                blue: blue,
                alpha: alpha
            )
        }

        return switch customColor {
        case let .uiColor(value):
            value
        case let .swiftUIColor(value):
            UIColor(value)
        }
    }
}

#endif
