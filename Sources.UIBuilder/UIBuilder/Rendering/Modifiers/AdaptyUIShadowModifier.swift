//
//  AdaptyUIShadowModifier.swift
//  AdaptyUIBuilder
//
//  Created by Alexey Goncharov on 3/21/25.
//

#if canImport(UIKit)

import SwiftUI

struct AdaptyUIShadowModifier: ViewModifier {
    private let color: AdaptyUIResolvedColorAsset?
    private let blurRadius: Double
    private let offset: CGSize

    init(
        color: AdaptyUIResolvedColorAsset?,
        blurRadius: Double,
        offset: CGSize
    ) {
        self.color = color
        self.blurRadius = blurRadius
        self.offset = offset
    }

    @EnvironmentObject
    private var assetsViewModel: AdaptyUIAssetsViewModel
    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme
    @Environment(\.adaptyScreenSize)
    private var screenSize: CGSize
    @Environment(\.adaptySafeAreaInsets)
    private var safeArea: EdgeInsets

    func body(content: Content) -> some View {
        content
            .shadow(
                color: self.color ?? .clear,
                radius: self.blurRadius,
                x: self.offset.width,
                y: self.offset.height
            )
    }
}

extension View {
    @ViewBuilder
    func shadow(
        color: AdaptyUIResolvedColorAsset?,
        blurRadius: Double?,
        offset: CGSize?
    ) -> some View {
        if let color, let blurRadius, let offset {
            self.modifier(
                AdaptyUIShadowModifier(
                    color: color,
                    blurRadius: blurRadius,
                    offset: offset
                )
            )
        } else {
            self
        }
    }
}

#endif
