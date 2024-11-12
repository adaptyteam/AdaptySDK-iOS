//
//  File.swift
//  Adapty
//
//  Created by Aleksey Goncharov on 12.11.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI
import UIKit

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyUI {
    @MainActor
    public final class PaywallConfiguration {
        public var locale: String { paywallViewModel.viewConfiguration.locale }
        
        package let eventsHandler: AdaptyEventsHandler
        package let paywallViewModel: AdaptyPaywallViewModel
        package let productsViewModel: AdaptyProductsViewModel
        package let actionsViewModel: AdaptyUIActionsViewModel
        package let sectionsViewModel: AdaptySectionsViewModel
        package let tagResolverViewModel: AdaptyTagResolverViewModel
        package let timerViewModel: AdaptyTimerViewModel
        package let screensViewModel: AdaptyScreensViewModel
        package let videoViewModel: AdaptyVideoViewModel
        
        package init(
            logId: String,
            paywall: AdaptyPaywallInterface,
            viewConfiguration: AdaptyUICore.LocalizedViewConfiguration,
            products: [AdaptyPaywallProduct]?,
            observerModeResolver: AdaptyObserverModeResolver?,
            tagResolver: AdaptyTagResolver?,
            timerResolver: AdaptyTimerResolver?
        ) {
            Log.ui.verbose("#\(logId)# init template: \(viewConfiguration.templateId), products: \(products?.count ?? 0), observerModeResolver: \(observerModeResolver != nil)")
            
            if AdaptyUI.isObserverModeEnabled, observerModeResolver == nil {
                Log.ui.warn("In order to handle purchases in Observer Mode enabled, provide the observerModeResolver!")
            } else if !AdaptyUI.isObserverModeEnabled, observerModeResolver != nil {
                Log.ui.warn("You should not pass observerModeResolver if you're using Adapty in Full Mode")
            }
            
            eventsHandler = AdaptyEventsHandler(logId: logId)
            tagResolverViewModel = AdaptyTagResolverViewModel(tagResolver: tagResolver)
            actionsViewModel = AdaptyUIActionsViewModel(eventsHandler: eventsHandler)
            sectionsViewModel = AdaptySectionsViewModel(logId: logId)
            paywallViewModel = AdaptyPaywallViewModel(
                eventsHandler: eventsHandler,
                paywall: paywall,
                viewConfiguration: viewConfiguration
            )
            productsViewModel = AdaptyProductsViewModel(
                eventsHandler: eventsHandler,
                paywallViewModel: paywallViewModel,
                products: products,
                observerModeResolver: observerModeResolver
            )
            screensViewModel = AdaptyScreensViewModel(
                eventsHandler: eventsHandler,
                viewConfiguration: viewConfiguration
            )
            timerViewModel = AdaptyTimerViewModel(
                timerResolver: timerResolver ?? AdaptyUIDefaultTimerResolver(),
                paywallViewModel: paywallViewModel,
                productsViewModel: productsViewModel,
                actionsViewModel: actionsViewModel,
                sectionsViewModel: sectionsViewModel,
                screensViewModel: screensViewModel
            )
            videoViewModel = AdaptyVideoViewModel(eventsHandler: eventsHandler)
            
            productsViewModel.loadProductsIfNeeded()
        }
    }
}

#endif
