//
//  AdaptyUISliderView.swift
//  Adapty
//
//  Created by Alex Goncharov on 15/01/2026.
//


#if canImport(UIKit)

import SwiftUI

struct AdaptyUISliderView: View {
    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme

    @EnvironmentObject var stateViewModel: AdaptyUIStateViewModel
    @EnvironmentObject var paywallViewModel: AdaptyUIPaywallViewModel
    @EnvironmentObject var productsViewModel: AdaptyUIProductsViewModel
    @EnvironmentObject var sectionsViewModel: AdaptyUISectionsViewModel
    @EnvironmentObject var screensViewModel: AdaptyUIScreensViewModel
    @EnvironmentObject var assetsViewModel: AdaptyUIAssetsViewModel

    private var slider: VC.Slider

    init(_ slider: VC.Slider) {
        self.slider = slider
    }
    
    @State var value = 0.0

    var body: some View {
        Slider(
            value: stateViewModel.createBinding(
                slider.value,
                defaultValue: 0.0
            ),
            in: slider.minValue ... slider.maxValue,
            step: slider.stepValue ?? 0.1
        )
    }
}

#endif
