//
//  AdaptyUIToggleView.swift
//
//
//  Created by Aleksey Goncharov on 30.05.2024.
//

#if canImport(UIKit)

import SwiftUI

struct AdaptyUIToggleView: View {
    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme
    @Environment(\.adaptyScreenInstance)
    private var screen: VS.ScreenInstance

    @EnvironmentObject
    private var stateViewModel: AdaptyUIStateViewModel
    @EnvironmentObject
    private var assetsViewModel: AdaptyUIAssetsViewModel

    private var toggle: VC.Toggle

    init(_ toggle: VC.Toggle) {
        self.toggle = toggle
    }

    var body: some View {
        Toggle(
            isOn: stateViewModel.createBinding(
                toggle.value,
                defaultValue: false,
                screen: screen
            )
        ) {
            EmptyView()
        }
        .tint(
            assetsViewModel.resolvedAsset(
                toggle.color,
                mode: colorScheme.toVCMode,
                screen: screen
            ).asColorAsset
        )
    }
}

#endif
