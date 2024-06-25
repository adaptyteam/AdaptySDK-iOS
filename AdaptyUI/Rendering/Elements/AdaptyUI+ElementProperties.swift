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

    @ViewBuilder
    func padding(_ insets: AdaptyUI.EdgeInsets?) -> some View {
        if let insets {
            padding(EdgeInsets(
                top: insets.top,
                leading: insets.leading,
                bottom: insets.bottom,
                trailing: insets.trailing
            ))
        } else {
            self
        }
    }
}

@available(iOS 15.0, *)
extension AdaptyUI.Color {
    var swiftuiColor: Color { Color(red: red, green: green, blue: blue, opacity: alpha) }
}

#endif
