//
//  AdaptyUIRangedFrameModifier.swift
//
//
//  Created by Aleksey Goncharov on 16.05.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct AdaptyUIRangedFrameModifier: ViewModifier {
    typealias Constraints = (min: CGFloat?, max: CGFloat?, shrink: Bool)

    @Environment(\.adaptyScreenSize)
    private var screenSize: CGSize
    @Environment(\.adaptySafeAreaInsets)
    private var safeArea: EdgeInsets
    @Environment(\.layoutDirection)
    private var layoutDirection: LayoutDirection

    var box: AdaptyUI.Box

    private func constraints(
        for lenght: AdaptyUI.Box.Length?,
        screenSize: CGFloat,
        safeAreaStart: Double,
        safeAreaEnd: Double
    ) -> Constraints {
        switch lenght {
        case let .min(unit): (min: unit.points(screenSize: screenSize, safeAreaStart: safeAreaStart, safeAreaEnd: safeAreaEnd), max: nil, false)
        case let .shrink(unit): (min: unit.points(screenSize: screenSize, safeAreaStart: safeAreaStart, safeAreaEnd: safeAreaEnd), max: nil, true)
        case .fillMax: (min: nil, max: .infinity, false)
        default: (min: nil, max: nil, false)
        }
    }

    func body(content: Content) -> some View {
        let wConstraints = self.constraints(
            for: self.box.width,
            screenSize: self.screenSize.width,
            safeAreaStart: safeArea.leading,
            safeAreaEnd: safeArea.trailing
        )
        let hConstraints = self.constraints(
            for: self.box.height,
            screenSize: self.screenSize.height,
            safeAreaStart: safeArea.top,
            safeAreaEnd: safeArea.bottom
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
                    minWidth: wConstraints.min,
                    maxWidth: wConstraints.max,
                    minHeight: hConstraints.min,
                    maxHeight: hConstraints.max,
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
    func rangedFrame(box: AdaptyUI.Box) -> some View {
        modifier(AdaptyUIRangedFrameModifier(box: box))
    }
}

#endif
