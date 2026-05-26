//
//  AdaptyUIBuilder+FlowConfiguration.swift
//  AdaptyUIBuilder
//
//  Created by Alexey Goncharov on 9/23/25.
//

#if canImport(UIKit)

import Foundation

@MainActor
public extension AdaptyUIBuilder {
    static func getPaywallConfiguration(
        forSchema schema: AdaptyUISchema,
        localeId: LocaleId?,
        products: [ProductResolver],
        tagResolver: AdaptyUITagResolver?,
        timerResolver: AdaptyUITimerResolver?,
        assetsResolver: AdaptyUIAssetsResolver?
    ) async throws -> FlowConfiguration {
        let viewConfiguration = try schema.extractUIConfiguration(
            id: UUID().uuidString,
            withLocaleId: localeId,
            envoriment: .init(
                sdkVersion: "",
                osName: "",
                osVersion: "",
                deviceModel: "",
                appBundleId: nil,
                appVersion: nil,
                appBuild: nil,
                appCurrentLocale: nil,
                userLocales: [],
                userUses24HourClock: true,
                flow: .init(
                    placementId: "",
                    variationId: "",
                    abTestName: "",
                    name: "",
                    products: []
                )
            )
        )

        return FlowConfiguration(
            logId: Log.stamp,
            viewConfiguration: viewConfiguration,
            products: products,
            tagResolver: tagResolver,
            timerResolver: timerResolver,
            assetsResolver: assetsResolver
        )
    }
}

public extension AdaptyUIBuilder {
    @MainActor
    final class FlowConfiguration {
        let eventsHandler: AdaptyUIEventsHandler

        let presentationViewModel: AdaptyUIPresentationViewModel
        let stateViewModel: AdaptyUIStateViewModel
        let actionHandler: AdaptyUIStateActionHandler
        let flowViewModel: AdaptyUIFlowViewModel
        let productsViewModel: AdaptyUIProductsViewModel
        let tagResolverViewModel: AdaptyUITagResolverViewModel
        let timerViewModel: AdaptyUITimerViewModel
        let screensViewModel: AdaptyUIScreensViewModel
        let assetsViewModel: AdaptyUIAssetsViewModel
        
        let logic: AdaptyUIBuilderAppLogic

        fileprivate let logId: String
        fileprivate let tagResolver: AdaptyUITagResolver?
        fileprivate let timerResolver: AdaptyUITimerResolver?
        fileprivate let assetsResolver: AdaptyUIAssetsResolver?

        init(
            logId: String,
            viewConfiguration: AdaptyUIConfiguration,
            products: [ProductResolver],
            tagResolver: AdaptyUITagResolver?,
            timerResolver: AdaptyUITimerResolver?,
            assetsResolver: AdaptyUIAssetsResolver?
        ) {
            self.logId = logId
            self.tagResolver = tagResolver
            self.timerResolver = timerResolver
            self.assetsResolver = assetsResolver
            
            eventsHandler = AdaptyUIEventsHandler(logId: logId)
            logic = AdaptyUIBuilderAppLogic(
                logId: logId,
                products: products,
                events: eventsHandler
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
            assetsViewModel = AdaptyUIAssetsViewModel(
                logId: logId,
                assetsResolver: assetsResolver ?? AdaptyUIDefaultAssetsResolver(),
                stateHolder: stateHolder
            )

            stateHolder.start()
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
