//
//  AdaptyUI+ElementProperties.swift
//
//
//  Created by Aleksey Goncharov on 3.4.24..
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, *)
extension AdaptyUI.Point {
    var unitPoint: UnitPoint { UnitPoint(x: x, y: y) }
}

@available(iOS 15.0, *)
extension AdaptyUI.ColorGradient.Item {
    var gradientStop: Gradient.Stop { Gradient.Stop(color: color.swiftuiColor, location: p) }
}

@available(iOS 15.0, *)
extension View {
    @ViewBuilder
    func applyingProperties(_ props: AdaptyUI.Element.Properties?, includeBackground: Bool) -> some View {
        decorate(with: props?.decorator, includeBackground: includeBackground)
            .offset(x: props?.offset.x ?? 0.0, y: props?.offset.y ?? 0.0)
            .padding(props?.padding)
    }
}

@available(iOS 15.0, *)
extension AdaptyUI.Mode<AdaptyUI.Color> {
    private func resolvedColor(style: UIUserInterfaceStyle) -> AdaptyUI.Color {
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

@available(iOS 15.0, *)
extension AdaptyUI.Color {
    var swiftuiColor: SwiftUI.Color {
        SwiftUI.Color(uiColor)
    }

    var uiColor: UIColor {
        UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

#endif
