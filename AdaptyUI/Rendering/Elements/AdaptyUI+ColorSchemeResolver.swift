//
//  AdaptyUI+ColorSchemeResolver.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 23.05.2025.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension VC.Mode {
    func usedColorScheme(_ colorScheme: ColorScheme) -> T {
        switch colorScheme {
        case .dark: mode(.dark)
        default: mode(.light)
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension VC.Mode<VC.VideoData> {
    func resolve(with resolver: AdaptyAssetsResolver, colorScheme: ColorScheme) -> VC.VideoData.Resolved {
        usedColorScheme(colorScheme).resolve(with: resolver)
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension VC.Mode<VC.ImageData> {
    func resolve(with resolver: AdaptyAssetsResolver, colorScheme: ColorScheme) -> VC.ImageData.Resolved {
        usedColorScheme(colorScheme).resolve(with: resolver)
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension VC.Mode<VC.Font> {
    func resolve(with resolver: AdaptyAssetsResolver, colorScheme: ColorScheme, withSize size: Double) -> VC.Font.Resolved {
        usedColorScheme(colorScheme).resolve(with: resolver, withSize: size)
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension VC.Mode<VC.Filling> {
    func resolve(with resolver: AdaptyAssetsResolver, colorScheme: ColorScheme) -> VC.Filling.Resolved {
        usedColorScheme(colorScheme).resolve(with: resolver)
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension VC.Mode<VC.Color> {
    func resolve(with resolver: AdaptyAssetsResolver, colorScheme: ColorScheme) -> SwiftUI.Color {
        usedColorScheme(colorScheme).resolve(with: resolver)
    }

//    @available(*, deprecated, message: "Use `resolve(with:, colorScheme:)` instead.")
    func resolve(with resolver: AdaptyAssetsResolver) -> UIColor {
        UIColor {
            let colorScheme: ColorScheme =
                switch $0.userInterfaceStyle {
                case .dark: .dark
                default: .light
                }

            let swiftColor: SwiftUI.Color = usedColorScheme(colorScheme).resolve(with: resolver)

            return UIColor(swiftColor)
        }
    }

//    @available(*, deprecated, message: "Use `resolve(with:, colorScheme:)` instead.")
    func resolve(with resolver: AdaptyAssetsResolver) -> SwiftUI.Color {
        let uiColor: UIColor = resolve(with: resolver)
        return SwiftUI.Color(uiColor)
    }
}

#endif
