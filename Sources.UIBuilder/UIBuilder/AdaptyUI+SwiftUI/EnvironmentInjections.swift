//
//  Untitled.swift
//  Adapty
//
//  Created by Alexey Goncharov on 12/30/25.
//

#if canImport(UIKit)

import SwiftUI

package extension View {
    func environmentObjects(
        stateViewModel: AdaptyUIStateViewModel,
        flowViewModel: AdaptyUIFlowViewModel,
        productsViewModel: AdaptyUIProductsViewModel,
        tagResolverViewModel: AdaptyUITagResolverViewModel,
        timerViewModel: AdaptyUITimerViewModel,
        screensViewModel: AdaptyUIScreensViewModel,
        assetsViewModel: AdaptyUIAssetsViewModel,
        customElementsViewModel: AdaptyUICustomElementsViewModel
    ) -> some View {
        environmentObject(stateViewModel)
            .environmentObject(flowViewModel)
            .environmentObject(productsViewModel)
            .environmentObject(tagResolverViewModel)
            .environmentObject(timerViewModel)
            .environmentObject(screensViewModel)
            .environmentObject(assetsViewModel)
            .environmentObject(customElementsViewModel)
    }
}

#endif

