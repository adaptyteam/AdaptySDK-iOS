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
        paywallViewModel: AdaptyUIPaywallViewModel,
        productsViewModel: AdaptyUIProductsViewModel,
        sectionsViewModel: AdaptyUISectionsViewModel,
        tagResolverViewModel: AdaptyUITagResolverViewModel,
        timerViewModel: AdaptyUITimerViewModel,
        screensViewModel: AdaptyUIScreensViewModel,
        assetsViewModel: AdaptyUIAssetsViewModel
    ) -> some View {
        environmentObject(stateViewModel)
            .environmentObject(paywallViewModel)
            .environmentObject(productsViewModel)
            .environmentObject(sectionsViewModel)
            .environmentObject(tagResolverViewModel)
            .environmentObject(timerViewModel)
            .environmentObject(screensViewModel)
            .environmentObject(assetsViewModel)
    }
}

#endif
