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
    @Environment(\.adaptySafeAreaInsets)
    private var safeArea: EdgeInsets
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
            content.frame(width: w.points(screenSize: screenSize.width, safeAreaStart: safeArea.leading, safeAreaEnd: safeArea.trailing),
                          height: h.points(screenSize: screenSize.height, safeAreaStart: safeArea.top, safeAreaEnd: safeArea.bottom),
                          alignment: alignment)
        case let (.fixed(w), _):
            content.frame(width: w.points(screenSize: screenSize.width, safeAreaStart: safeArea.leading, safeAreaEnd: safeArea.trailing),
                          height: nil,
                          alignment: alignment)
        case let (_, .fixed(h)):
            content.frame(width: nil,
                          height: h.points(screenSize: screenSize.height, safeAreaStart: safeArea.top, safeAreaEnd: safeArea.bottom),
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

// TODO: Move Out
@available(iOS 15.0, *)
package extension AdaptyUI.Unit {
    package func points(screenSize: Double, safeAreaStart: Double, safeAreaEnd: Double) -> Double {
        switch self {
        case let .point(value): value
        case let .screen(value): value * screenSize
        case let .safeArea(value):
            switch value {
            case .start: safeAreaStart
            case .end: safeAreaEnd
            }
        }
    }
}
#endif
