//
//  AdaptyUIStateActionHandler.swift
//  Adapty
//
//  Created by Alexey Goncharov on 12/18/25.
//

#if canImport(UIKit)

import Foundation
import SwiftUI

@MainActor
package final class AdaptyUIStateActionHandler: AdaptyUIActionHandler {
    private let productsViewModel: AdaptyUIProductsViewModel
    private let screensViewModel: AdaptyUIScreensViewModel
    private let logic: AdaptyUIBuilderLogic
    
    package init(
        productsViewModel: AdaptyUIProductsViewModel,
        screensViewModel: AdaptyUIScreensViewModel,
        logic: AdaptyUIBuilderLogic
    ) {
        self.productsViewModel = productsViewModel
        self.screensViewModel = screensViewModel
        self.logic = logic
    }
    
    package nonisolated func openUrl(
        url: URL,
        openIn: VC.Action.WebOpenInParameter
    ) {
        Task { @MainActor in
            logic.reportDidPerformAction(.openURL(url: url))
        }
    }
    
    package nonisolated func userCustomAction(id: String) {
        Task { @MainActor in
            logic.reportDidPerformAction(.custom(id: id))
        }
    }
    
    package nonisolated func purchaseProduct(
        productId: String,
        paywallId: String,
        service: VC.Action.PaymentService
    ) {
        Task { @MainActor in
            productsViewModel.purchaseProduct(id: productId, service: service)
        }
    }
    
    package nonisolated func openWebPaywall(
        openIn: VC.Action.WebOpenInParameter
    ) {
        // TODO: Deperecated
    }
    
    package nonisolated func restorePurchases() {
        Task { @MainActor in
            productsViewModel.restorePurchases()
        }
    }
    
    package nonisolated func closeAll() {
        Task { @MainActor in
            logic.reportDidPerformAction(.close)
        }
    }
    
    package nonisolated func selectProduct(
        productId: String,
        paywallId: String
    ) {
        Task { @MainActor in
            // TODO: move animation out of here
            withAnimation(.linear(duration: 0.0)) {
                productsViewModel.selectProduct(
                    id: productId,
                    forGroupId: paywallId // TODO: x check
                )
            }
        }
    }

    package nonisolated func openScreen(
        instance: VS.ScreenInstance,
        transitionId: String
    ) {
        Task { @MainActor in
            screensViewModel.present(
                screen: instance,
                transitionId: transitionId,
                completion: {
                    // TODO: x report completion to Script
                }
            )
        }
    }
    
    package nonisolated func closeScreen(
        navigatorId: String,
        transitionId: String
    ) {
        Task { @MainActor in
            screensViewModel.dismiss(
                navigatorId: navigatorId,
                transitionId: transitionId,
                completion: {
                    // TODO: x report completion to Script
                }
            )
        }
    }
}

#endif
