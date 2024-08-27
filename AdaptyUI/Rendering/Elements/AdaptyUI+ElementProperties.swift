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
extension AdaptyUI.Color {
    var swiftuiColor: Color {
        Color(uiColor)
    }

    var uiColor: UIColor {
        UIColor { traits -> UIColor in
            traits.userInterfaceStyle == .dark ?
                UIColor(red: 1.0 - red, green: 1.0 - green, blue: 1.0 - blue, alpha: alpha) :
                UIColor(red: red, green: green, blue: blue, alpha: alpha)
        }
    }
}

#endif
