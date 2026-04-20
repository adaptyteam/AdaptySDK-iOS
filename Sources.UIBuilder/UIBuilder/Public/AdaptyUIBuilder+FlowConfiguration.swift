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
                userUses24HourClock: true
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
            flowViewModel.logShowPaywall()
        }

        func reportOnDisappear() {
            logic.reportViewDidDisappear()
            flowViewModel.resetLogShowPaywall()
            productsViewModel.resetSelectedProducts()
            timerViewModel.resetTimersState()
        }
    }
}

#endif
