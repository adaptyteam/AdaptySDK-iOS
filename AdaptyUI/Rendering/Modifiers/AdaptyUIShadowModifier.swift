//
//  AdaptyUIShadowModifier.swift
//  Adapty
//
//  Created by Alexey Goncharov on 3/21/25.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct AdaptyShadowModifier: ViewModifier {
    private let filling: AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.Filling>
    private let blurRadius: Double
    private let offset: AdaptyViewConfiguration.Offset

    init(
        filling: AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.Filling>,
        blurRadius: Double,
        offset: AdaptyViewConfiguration.Offset
    ) {
        self.filling = filling
        self.blurRadius = blurRadius
        self.offset = offset
    }

    init(shadow: AdaptyViewConfiguration.Shadow) {
        self.filling = shadow.filling
        self.blurRadius = shadow.blurRadius
        self.offset = shadow.offset
    }

    @EnvironmentObject
    private var assetsViewModel: AdaptyAssetsViewModel
    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme
    @Environment(\.adaptyScreenSize)
    private var screenSize: CGSize
    @Environment(\.adaptySafeAreaInsets)
    private var safeArea: EdgeInsets

    func body(content: Content) -> some View {
        content
            .shadow(
                color: self.filling
                    .of(self.colorScheme)
                    .asSolidColor?
                    .swiftuiColor(self.assetsViewModel.assetsResolver) ?? .clear,
                radius: self.blurRadius,
                x: self.offset.x.points(
                    screenSize: self.screenSize.width,
                    safeAreaStart: self.safeArea.leading,
                    safeAreaEnd: self.safeArea.trailing
                ),
                y: self.offset.y.points(
                    screenSize: self.screenSize.height,
                    safeAreaStart: self.safeArea.top,
                    safeAreaEnd: self.safeArea.bottom
                )
            )
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension View {
    @ViewBuilder
    func shadow(
        filling: AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.Filling>?,
        blurRadius: Double?,
        offset: AdaptyViewConfiguration.Offset?
    ) -> some View {
        if let filling, let blurRadius, let offset {
            self.modifier(
                AdaptyShadowModifier(
                    filling: filling,
                    blurRadius: blurRadius,
                    offset: offset
                )
            )
        } else {
            self
        }
    }

    @ViewBuilder
    func shadow(_ shadow: AdaptyViewConfiguration.Shadow?) -> some View {
        if let shadow {
            self.modifier(
                AdaptyShadowModifier(shadow: shadow)
            )
        } else {
            self
        }
    }
}

#endif
