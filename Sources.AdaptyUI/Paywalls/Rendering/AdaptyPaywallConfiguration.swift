//
//  File.swift
//  Adapty
//
//  Created by Aleksey Goncharov on 12.11.2024.
//

#if canImport(UIKit)

import Adapty
import AdaptyUIBuilder
import SwiftUI
import UIKit

public extension AdaptyUI {
    @MainActor
    final class PaywallConfiguration {
        public var id: String { paywallViewModel.viewConfiguration.id }
        public var locale: String { paywallViewModel.viewConfiguration.locale }
        public var isRightToLeft: Bool { paywallViewModel.viewConfiguration.isRightToLeft }

        package let eventsHandler: AdaptyEventsHandler

        package let presentationViewModel: AdaptyUIPresentationViewModel
        package let paywallViewModel: AdaptyUIPaywallViewModel
        package let productsViewModel: AdaptyUIProductsViewModel
        package let actionsViewModel: AdaptyUIActionsViewModel
        package let sectionsViewModel: AdaptyUISectionsViewModel
        package let tagResolverViewModel: AdaptyUITagResolverViewModel
        package let timerViewModel: AdaptyUITimerViewModel
        package let screensViewModel: AdaptyUIScreensViewModel
        package let assetsViewModel: AdaptyUIAssetsViewModel

        private let logic: AdaptyUILogic

        fileprivate let logId: String
        fileprivate let observerModeResolver: AdaptyObserverModeResolver?
        fileprivate let tagResolver: AdaptyUITagResolver?
        fileprivate let timerResolver: AdaptyTimerResolver?
        fileprivate let assetsResolver: AdaptyUIAssetsResolver?

        package init(
            logId: String,
            paywall: AdaptyPaywall,
            viewConfiguration: AdaptyUIConfiguration,
            products: [AdaptyPaywallProduct]?,
            observerModeResolver: AdaptyObserverModeResolver?,
            tagResolver: AdaptyUITagResolver?,
            timerResolver: AdaptyTimerResolver?,
            assetsResolver: AdaptyUIAssetsResolver?
        ) {
            Log.ui.verbose("#\(logId)# init template: \(viewConfiguration.deprecated_defaultScreen.templateId), products: \(products?.count ?? 0), observerModeResolver: \(observerModeResolver != nil)")

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
            logic = AdaptyUILogic(
                logId: logId,
                paywall: paywall,
                events: eventsHandler,
                observerModeResolver: observerModeResolver
            )
            presentationViewModel = AdaptyUIPresentationViewModel(logId: logId, logic: logic)
            tagResolverViewModel = AdaptyUITagResolverViewModel(tagResolver: tagResolver)
            actionsViewModel = AdaptyUIActionsViewModel(logId: logId, logic: logic)
            sectionsViewModel = AdaptyUISectionsViewModel(logId: logId)
            paywallViewModel = AdaptyUIPaywallViewModel(
                logId: logId,
                logic: logic,
                viewConfiguration: viewConfiguration
            )
            productsViewModel = AdaptyUIProductsViewModel(
                logId: logId,
                logic: logic,
                presentationViewModel: presentationViewModel,
                paywallViewModel: paywallViewModel,
                products: products?.map { AdaptyPaywallProductWrapper.full($0) }
            )
            screensViewModel = AdaptyUIScreensViewModel(
                logId: logId,
                viewConfiguration: viewConfiguration
            )
            timerViewModel = AdaptyUITimerViewModel(
                logId: logId,
                timerResolver: timerResolver ?? AdaptyUIDefaultTimerResolver(),
                paywallViewModel: paywallViewModel,
                productsViewModel: productsViewModel,
                actionsViewModel: actionsViewModel,
                sectionsViewModel: sectionsViewModel,
                screensViewModel: screensViewModel
            )
            assetsViewModel = AdaptyUIAssetsViewModel(
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
