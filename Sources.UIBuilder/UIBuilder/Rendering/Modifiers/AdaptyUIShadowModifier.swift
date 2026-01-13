//
//  AdaptyUIShadowModifier.swift
//  AdaptyUIBuilder
//
//  Created by Alexey Goncharov on 3/21/25.
//

#if canImport(UIKit)

import SwiftUI

struct AdaptyUIShadowModifier: ViewModifier {
    private let asset: VC.AssetReference
    private let blurRadius: Double
    private let offset: CGSize

    init(
        asset: VC.AssetReference,
        blurRadius: Double,
        offset: CGSize
    ) {
        self.asset = asset
        self.blurRadius = blurRadius
        self.offset = offset
    }

    @EnvironmentObject
    private var assetsViewModel: AdaptyUIAssetsViewModel
    @EnvironmentObject
    private var stateViewModel: AdaptyUIStateViewModel
    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme
    @Environment(\.adaptyScreenSize)
    private var screenSize: CGSize
    @Environment(\.adaptySafeAreaInsets)
    private var safeArea: EdgeInsets

    func body(content: Content) -> some View {
        content
            .shadow(
                color: self.asset
                    .resolveSolidColor(
                        with: self.assetsViewModel.assetsResolver,
                        stateViewModel: self.stateViewModel,
                        mode: self.colorScheme.toVCMode
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
        asset: VC.AssetReference?,
        blurRadius: Double?,
        offset: CGSize?
    ) -> some View {
        if let asset, let blurRadius, let offset {
            self.modifier(
                AdaptyUIShadowModifier(
                    asset: asset,
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
