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
extension VC.ColorGradient.Item {
    var gradientStop: Gradient.Stop { Gradient.Stop(color: color.swiftuiColor, location: p) }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension View {
    @ViewBuilder
    func applyingProperties(_ props: VC.Element.Properties?, includeBackground: Bool) -> some View {
        decorate(with: props?.decorator, includeBackground: includeBackground)
            .offset(x: props?.offset.x ?? 0.0, y: props?.offset.y ?? 0.0)
            .padding(props?.padding)
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension VC.Mode<VC.Color> {
    private func resolvedColor(style: UIUserInterfaceStyle) -> VC.Color {
        switch style {
        case .dark:
            return mode(.dark)
        default:
            return mode(.light)
        }
    }

    var swiftuiColor: SwiftUI.Color {
        SwiftUI.Color(uiColor)
    }

    var uiColor: UIColor {
        UIColor {
            resolvedColor(style: $0.userInterfaceStyle).uiColor
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension VC.Color {
    var swiftuiColor: SwiftUI.Color {
        SwiftUI.Color(uiColor)
    }

    var uiColor: UIColor {
        UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

#endif
