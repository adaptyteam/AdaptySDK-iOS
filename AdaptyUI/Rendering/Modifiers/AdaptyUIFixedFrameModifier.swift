//
//  AdaptyUIFixedFrameModifier.swift
//
//
//  Created by Aleksey Goncharov on 16.05.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, *)
struct AdaptyUIFixedFrameModifier: ViewModifier {
    @Environment(\.adaptyScreenSize)
    private var screenSize: CGSize
    @Environment(\.layoutDirection)
    private var layoutDirection: LayoutDirection

    var box: AdaptyUI.Box

    func body(content: Content) -> some View {
        let alignment = Alignment.from(
            horizontal: box.horizontalAlignment.swiftuiValue(with: layoutDirection),
            vertical: box.verticalAlignment.swiftuiValue
        )

        switch (box.width, box.height) {
        case let (.fixed(w), .fixed(h)):
            content.frame(width: w.points(screenSize: screenSize.width),
                          height: h.points(screenSize: screenSize.height),
                          alignment: alignment)
        case let (.fixed(w), _):
            content.frame(width: w.points(screenSize: screenSize.width),
                          height: nil,
                          alignment: alignment)
        case let (_, .fixed(h)):
            content.frame(width: nil,
                          height: h.points(screenSize: screenSize.height),
                          alignment: alignment)
        default:
            content
        }
    }
}

@available(iOS 15.0, *)
extension View {
    func fixedFrame(box: AdaptyUI.Box) -> some View {
        modifier(AdaptyUIFixedFrameModifier(box: box))
    }
}

@available(iOS 15.0, *)
extension AdaptyUI.Unit {
    package func points(screenSize: Double) -> Double {
        switch self {
        case let .point(value): value
        case let .screen(value): value * screenSize
        case let .safeArea(value): 0
        }
    }
}
#endif
