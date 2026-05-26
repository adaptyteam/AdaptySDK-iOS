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
    final class FlowConfiguration {
        public var id: String { flowViewModel.viewConfiguration.id }
        public var locale: String { flowViewModel.viewConfiguration.localizationId }
        public var isRightToLeft: Bool { flowViewModel.viewConfiguration.isRightToLeft }

        package let eventsHandler: AdaptyEventsHandler

        package let presentationViewModel: AdaptyUIPresentationViewModel
        package let stateViewModel: AdaptyUIStateViewModel
        package let actionHandler: AdaptyUIStateActionHandler
        package let flowViewModel: AdaptyUIFlowViewModel
        package let productsViewModel: AdaptyUIProductsViewModel
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
        fileprivate let systemRequestsHandler: AdaptyUISystemRequestsHandler?

        package init(
            logId: String,
            flow: AdaptyFlow,
            viewConfiguration: AdaptyUIConfiguration,
            products: [AdaptyPaywallProduct]?,
            observerModeResolver: AdaptyObserverModeResolver?,
            tagResolver: AdaptyUITagResolver?,
            timerResolver: AdaptyTimerResolver?,
            assetsResolver: AdaptyUIAssetsResolver?,
            systemRequestsHandler: AdaptyUISystemRequestsHandler? = nil
        ) {
            Log.ui.verbose("#\(logId)# init products: \(products?.count ?? 0), observerModeResolver: \(observerModeResolver != nil)")

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
            self.systemRequestsHandler = systemRequestsHandler
            
            eventsHandler = AdaptyEventsHandler(logId: logId)
            logic = AdaptyUILogic(
                logId: logId,
                flow: flow,
                viewConfigurationId: viewConfiguration.id,
                events: eventsHandler,
                observerModeResolver: observerModeResolver
            )
            presentationViewModel = AdaptyUIPresentationViewModel(logId: logId, logic: logic)
            tagResolverViewModel = AdaptyUITagResolverViewModel(tagResolver: tagResolver)
            flowViewModel = AdaptyUIFlowViewModel(
                logId: logId,
                logic: logic,
                viewConfiguration: viewConfiguration
            )
            productsViewModel = AdaptyUIProductsViewModel(
                logId: logId,
                logic: logic,
                presentationViewModel: presentationViewModel,
                flowViewModel: flowViewModel,
                products: products
            )
            screensViewModel = AdaptyUIScreensViewModel(
                logId: logId,
                viewConfiguration: viewConfiguration
            )
            actionHandler = AdaptyUIStateActionHandler(
                productsViewModel: productsViewModel,
                screensViewModel: screensViewModel,
                logic: logic
            )
            let stateHolder = AdaptyUIStateHolder(
                logId: logId,
                actionHandler: actionHandler,
                viewConfiguration: viewConfiguration,
                isInspectable: false
            )
            stateViewModel = AdaptyUIStateViewModel(
                logId: logId,
                logic: logic,
                stateHolder: stateHolder
            )
            actionHandler.stateViewModel = stateViewModel
            let timerViewModel = AdaptyUITimerViewModel(
                logId: logId,
                timerResolver: timerResolver ?? AdaptyUIDefaultTimerResolver(),
                stateViewModel: stateViewModel,
                flowViewModel: flowViewModel,
                productsViewModel: productsViewModel,
                screensViewModel: screensViewModel
            )
            self.timerViewModel = timerViewModel
            actionHandler.timerViewModel = timerViewModel
            timerViewModel.callbackHandler = actionHandler
            actionHandler.systemRequestsHandler = systemRequestsHandler
            assetsViewModel = AdaptyUIAssetsViewModel(
                logId: logId,
                assetsResolver: assetsResolver ?? AdaptyUIDefaultAssetsResolver(),
                stateHolder: stateHolder
            )

            productsViewModel.onProductsLoaded = { [weak stateHolder] resolvers in
                let constants = resolvers.compactMap { $0 as? AdaptyPaywallProduct }.asUIBuilderFlowProducts()
                stateHolder?.setProducts(constants)
            }

            stateHolder.start()

            if let products, !products.isEmpty {
                stateHolder.setProducts(products.asUIBuilderFlowProducts())
            }

            productsViewModel.loadProductsIfNeeded()
        }

        func reportOnAppear() {
            logic.reportViewDidAppear()
            flowViewModel.logShowFlow()
            timerViewModel.resumeTimers()
        }

        func reportOnDisappear() {
            logic.reportViewDidDisappear()
            timerViewModel.pauseTimers()
        }

        /// Resets the transient runtime state of this configuration so it can
        /// be presented again as a fresh paywall view.
        ///
        /// By default a `FlowConfiguration` is single-shot: it deduplicates
        /// the `paywall_showed` event and keeps its in-memory timer state for
        /// the lifetime of the instance. Cross-platform SDKs that cache and
        /// re-present the same configuration should call this method before
        /// each new presentation to:
        ///
        /// - re-arm the `paywall_showed` event so it fires again on the next
        ///   `viewDidAppear`;
        /// - clear local timer end dates and pending callbacks (timers with
        ///   `continue` or `persisted` behavior keep their persisted source
        ///   of truth and will resume from it on the next `setTimer` call).
        ///
        /// If you only need a clean state for a single presentation, prefer
        /// creating a new `FlowConfiguration` instead.
        public func prepareForReuse() {
            Log.ui.verbose("#\(logId)# prepareForReuse")
            flowViewModel.prepareForReuse()
            timerViewModel.prepareForReuse()
            stateViewModel.prepareForReuse()
        }
    }
}

#endif
