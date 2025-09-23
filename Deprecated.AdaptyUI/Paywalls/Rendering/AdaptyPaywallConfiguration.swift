//
//  File.swift
//  Adapty
//
//  Created by Aleksey Goncharov on 12.11.2024.
//

#if canImport(UIKit)

import Adapty
import AdaptyUIBuider
import SwiftUI
import UIKit

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
public typealias AdaptyTimerResolver = AdaptyUIBuider.AdaptyTimerResolver

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
public typealias AdaptyTagResolver = AdaptyUIBuider.AdaptyTagResolver

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
public typealias AdaptyAssetsResolver = AdaptyUIBuider.AdaptyAssetsResolver

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
public typealias AdaptyCustomAsset = AdaptyUIBuider.AdaptyCustomAsset

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
struct AdaptyObserverResolverHolder: AdaptyUIBuilderObserverModeResolver {
    let logId: String
    let observerModeResolver: AdaptyObserverModeResolver?

    package func observerMode(
        didInitiatePurchase product: ProductResolver,
        onStartPurchase: @escaping () -> Void,
        onFinishPurchase: @escaping () -> Void
    ) {
        guard let product = product as? AdaptyPaywallProduct else {
            Log.ui.error("#\(logId)# observerMode_didInitiatePurchase: WRONG INJECTION")
            return
        }

        observerModeResolver?.observerMode(
            didInitiatePurchase: product,
            onStartPurchase: onStartPurchase,
            onFinishPurchase: onFinishPurchase
        )
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
public extension AdaptyUI {
    @MainActor
    final class PaywallConfiguration {
        public var id: String { paywallViewModel.viewConfiguration.id }
        public var locale: String { paywallViewModel.viewConfiguration.locale }
        public var isRightToLeft: Bool { paywallViewModel.viewConfiguration.isRightToLeft }

        package let eventsHandler: AdaptyEventsHandler

        package let presentationViewModel: AdaptyPresentationViewModel
        package let paywallViewModel: AdaptyPaywallViewModel
        package let productsViewModel: AdaptyProductsViewModel
        package let actionsViewModel: AdaptyUIActionsViewModel
        package let sectionsViewModel: AdaptySectionsViewModel
        package let tagResolverViewModel: AdaptyTagResolverViewModel
        package let timerViewModel: AdaptyTimerViewModel
        package let screensViewModel: AdaptyScreensViewModel
        package let assetsViewModel: AdaptyAssetsViewModel

        private let logic: AdaptyUILogic

        fileprivate let logId: String
        fileprivate let observerModeResolver: AdaptyObserverModeResolver?
        fileprivate let tagResolver: AdaptyTagResolver?
        fileprivate let timerResolver: AdaptyTimerResolver?
        fileprivate let assetsResolver: AdaptyAssetsResolver?

        fileprivate let observerResolverHolder: AdaptyObserverResolverHolder

        package init(
            logId: String,
            paywall: AdaptyPaywall,
            viewConfiguration: AdaptyUIConfiguration,
            products: [AdaptyPaywallProduct]?,
            observerModeResolver: AdaptyObserverModeResolver?,
            tagResolver: AdaptyTagResolver?,
            timerResolver: AdaptyTimerResolver?,
            assetsResolver: AdaptyAssetsResolver?
        ) {
            Log.ui.verbose("#\(logId)# init template: \(viewConfiguration.templateId), products: \(products?.count ?? 0), observerModeResolver: \(observerModeResolver != nil)")

            if AdaptyUI.isObserverModeEnabled, observerModeResolver == nil {
                Log.ui.warn("In order to handle purchases in Observer Mode enabled, provide the observerModeResolver!")
            } else if !AdaptyUI.isObserverModeEnabled, observerModeResolver != nil {
                Log.ui.warn("You should not pass observerModeResolver if you're using Adapty in Full Mode")
            }

            self.logId = logId
            self.observerModeResolver = observerModeResolver
            self.tagResolver = tagResolver
            self.timerResolver = timerResolver
            self.assetsResolver = assetsResolver

            eventsHandler = AdaptyEventsHandler(logId: logId)
            logic = AdaptyUILogic(logId: logId, paywall: paywall, events: eventsHandler)

//            tagResolverHolder = AdaptyTagResolverHolder(tagResolver: tagResolver)
            observerResolverHolder = AdaptyObserverResolverHolder(
                logId: logId,
                observerModeResolver: observerModeResolver
            )
            presentationViewModel = AdaptyPresentationViewModel(logId: logId, logic: logic)
            tagResolverViewModel = AdaptyTagResolverViewModel(tagResolver: tagResolver)
            actionsViewModel = AdaptyUIActionsViewModel(logId: logId, logic: logic)
            sectionsViewModel = AdaptySectionsViewModel(logId: logId)
            paywallViewModel = AdaptyPaywallViewModel(
                logId: logId,
                logic: logic,
                viewConfiguration: viewConfiguration
            )
            productsViewModel = AdaptyProductsViewModel(
                logId: logId,
                logic: logic,
                presentationViewModel: presentationViewModel,
                paywallViewModel: paywallViewModel,
                products: products?.map { AdaptyPaywallProductWrapper.full($0) },
                observerModeResolver: observerResolverHolder
            )
            screensViewModel = AdaptyScreensViewModel(
                logId: logId,
                viewConfiguration: viewConfiguration
            )
            timerViewModel = AdaptyTimerViewModel(
                logId: logId,
                timerResolver: timerResolver ?? AdaptyUIDefaultTimerResolver(),
                paywallViewModel: paywallViewModel,
                productsViewModel: productsViewModel,
                actionsViewModel: actionsViewModel,
                sectionsViewModel: sectionsViewModel,
                screensViewModel: screensViewModel
            )
            assetsViewModel = AdaptyAssetsViewModel(
                assetsResolver: assetsResolver ?? AdaptyUIDefaultAssetsResolver()
            )

            productsViewModel.loadProductsIfNeeded()
        }

        func reportOnAppear() {
            logic.reportViewDidAppear()
            paywallViewModel.logShowPaywall()
        }

        func reportOnDisappear() {
            logic.reportViewDidDisappear()
            paywallViewModel.resetLogShowPaywall()
            productsViewModel.resetSelectedProducts()
            sectionsViewModel.resetSectionsState()
            timerViewModel.resetTimersState()
            screensViewModel.resetScreensStack()
        }
    }
}

#endif
