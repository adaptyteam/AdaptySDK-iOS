//
//  AdaptyUIRangedFrameModifier.swift
//
//
//  Created by Aleksey Goncharov on 16.05.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 13.0, *)
struct AdaptyUIRangedFrameModifier: ViewModifier {
    @Environment(\.adaptyScreenSize)
    private var screenSize: CGSize

    var box: AdaptyUI.Box

    private func constraints(for lenght: AdaptyUI.Box.Length?, screenSize: CGFloat) -> (CGFloat?, CGFloat?) {
        switch lenght {
        case let .min(unit): (unit.points(screenSize: screenSize), nil)
        case .fillMax: (nil, .infinity)
        default: (nil, nil)
        }
    }

    func body(content: Content) -> some View {
        let wConstraints = self.constraints(for: self.box.width, screenSize: self.screenSize.width)
        let hConstraints = self.constraints(for: self.box.height, screenSize: self.screenSize.height)

        if wConstraints.0 == nil &&
            wConstraints.1 == nil &&
            hConstraints.0 == nil &&
            hConstraints.1 == nil
        {
            content
        } else {
            content
                .frame(
                    minWidth: wConstraints.0,
                    maxWidth: wConstraints.1,
                    minHeight: hConstraints.0,
                    maxHeight: hConstraints.1,
                    alignment: .from(horizontal: self.box.horizontalAlignment,
                                     vertical: self.box.verticalAlignment)
                )
        }
    }
}

@available(iOS 13.0, *)
extension View {
    func rangedFrame(box: AdaptyUI.Box) -> some View {
        modifier(AdaptyUIRangedFrameModifier(box: box))
    }
}

#endif
