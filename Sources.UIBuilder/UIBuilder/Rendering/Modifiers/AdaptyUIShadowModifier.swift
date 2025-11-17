//
//  AdaptyUIShadowModifier.swift
//  AdaptyUIBuilder
//
//  Created by Alexey Goncharov on 3/21/25.
//

#if canImport(UIKit)

import SwiftUI

struct AdaptyUIShadowModifier: ViewModifier {
    private let filling: VC.Mode<VC.Filling>
    private let blurRadius: Double
    private let offset: CGSize

    init(
        filling: VC.Mode<VC.Filling>,
        blurRadius: Double,
        offset: CGSize
    ) {
        self.filling = filling
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
                color: self.filling
                    .asSolidColor?
                    .resolve(
                        with: self.assetsViewModel.assetsResolver,
                        colorScheme: self.colorScheme
                    ) ?? .clear,
                radius: self.blurRadius,
                x: self.offset.width,
                y: self.offset.height
            )
    }
}

extension View {
    @ViewBuilder
    func shadow(
        filling: VC.Mode<VC.Filling>?,
        blurRadius: Double?,
        offset: CGSize?
    ) -> some View {
        if let filling, let blurRadius, let offset {
            self.modifier(
                AdaptyUIShadowModifier(
                    filling: filling,
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
