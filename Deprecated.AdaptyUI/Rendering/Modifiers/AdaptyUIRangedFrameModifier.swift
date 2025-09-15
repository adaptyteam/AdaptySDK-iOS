//
//  AdaptyUIRangedFrameModifier.swift
//
//
//  Created by Aleksey Goncharov on 16.05.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

extension Double {
    var cgFloatValue: CGFloat { CGFloat(self) }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct AdaptyUIRangedFrameModifier: ViewModifier {
    typealias Constraints = (min: Double?, max: Double?, shrink: Bool)

    @Environment(\.adaptyScreenSize)
    private var screenSize: CGSize
    @Environment(\.adaptySafeAreaInsets)
    private var safeArea: EdgeInsets
    @Environment(\.layoutDirection)
    private var layoutDirection: LayoutDirection

    var box: VC.Box

    private func constraints(
        for lenght: VC.Box.Length?,
        screenSize: CGFloat,
        safeAreaStart: Double,
        safeAreaEnd: Double
    ) -> Constraints {
        switch lenght {
        case let .flexible(min, max):
            (
                min: min?.points(
                    screenSize: screenSize,
                    safeAreaStart: safeAreaStart,
                    safeAreaEnd: safeAreaEnd
                ),
                max: max?.points(
                    screenSize: screenSize,
                    safeAreaStart: safeAreaStart,
                    safeAreaEnd: safeAreaEnd
                ),
                false
            )
        case let .shrinkable(min, max):
            (
                min: min.points(
                    screenSize: screenSize,
                    safeAreaStart: safeAreaStart,
                    safeAreaEnd: safeAreaEnd
                ),
                max: max?.points(
                    screenSize: screenSize,
                    safeAreaStart: safeAreaStart,
                    safeAreaEnd: safeAreaEnd
                ),
                true
            )
        case .fillMax: (min: nil, max: .infinity, false)
        default: (min: nil, max: nil, false)
        }
    }

    func body(content: Content) -> some View {
        let wConstraints = self.constraints(
            for: self.box.width,
            screenSize: self.screenSize.width,
            safeAreaStart: self.safeArea.leading,
            safeAreaEnd: self.safeArea.trailing
        )
        let hConstraints = self.constraints(
            for: self.box.height,
            screenSize: self.screenSize.height,
            safeAreaStart: self.safeArea.top,
            safeAreaEnd: self.safeArea.bottom
        )

        if wConstraints.min == nil && wConstraints.max == nil && wConstraints.shrink == false &&
            hConstraints.min == nil && hConstraints.max == nil && hConstraints.shrink == false
        {
            content
        } else if wConstraints.min == nil && wConstraints.max == nil &&
            hConstraints.min == nil && hConstraints.max == nil
        {
            content
                .fixedSize(
                    horizontal: wConstraints.shrink,
                    vertical: hConstraints.shrink
                )
        } else {
            content
                .frame(
                    minWidth: wConstraints.min?.cgFloatValue,
                    maxWidth: wConstraints.max?.cgFloatValue,
                    minHeight: hConstraints.min?.cgFloatValue,
                    maxHeight: hConstraints.max?.cgFloatValue,
                    alignment: .from(
                        horizontal: self.box.horizontalAlignment.swiftuiValue(with: self.layoutDirection),
                        vertical: self.box.verticalAlignment.swiftuiValue
                    )
                )
                .fixedSize(
                    horizontal: wConstraints.shrink,
                    vertical: hConstraints.shrink
                )
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension View {
    func rangedFrame(box: VC.Box) -> some View {
        modifier(AdaptyUIRangedFrameModifier(box: box))
    }
}

#endif
