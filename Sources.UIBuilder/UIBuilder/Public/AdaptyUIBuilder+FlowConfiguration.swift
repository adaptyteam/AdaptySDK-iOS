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
        assetsResolver: AdaptyUIAssetsResolver?,
        customElementsResolver: (any AdaptyUICustomElementsResolver)? = nil
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
            assetsResolver: assetsResolver,
            customElementsResolver: customElementsResolver
        )
    }
}

package extension AdaptyUISchema {
    @available(*, deprecated,  message: "Don't use optional localeId")
    func extractUIConfiguration(id: String, withLocaleId localeId: LocaleId?, envoriment: VC.EnvironmentConstants) throws -> AdaptyUIConfiguration {
        try extractUIConfiguration(
            id: id,
            withLocaleId: localeId ?? defaultLocalId ?? "en",
            envoriment: envoriment
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
        let customElementsViewModel: AdaptyUICustomElementsViewModel
        let timerViewModel: AdaptyUITimerViewModel
        let screensViewModel: AdaptyUIScreensViewModel
        let assetsViewModel: AdaptyUIAssetsViewModel
        
        let logic: AdaptyUIBuilderAppLogic

        fileprivate let logId: String
        fileprivate let tagResolver: AdaptyUITagResolver?
        fileprivate let timerResolver: AdaptyUITimerResolver?
        fileprivate let assetsResolver: AdaptyUIAssetsResolver?
        fileprivate let customElementsResolver: (any AdaptyUICustomElementsResolver)?

        init(
            logId: String,
            viewConfiguration: AdaptyUIConfiguration,
            products: [ProductResolver],
            tagResolver: AdaptyUITagResolver?,
            timerResolver: AdaptyUITimerResolver?,
            assetsResolver: AdaptyUIAssetsResolver?,
            customElementsResolver: (any AdaptyUICustomElementsResolver)? = nil
        ) {
            self.logId = logId
            self.tagResolver = tagResolver
            self.timerResolver = timerResolver
            self.assetsResolver = assetsResolver
            self.customElementsResolver = customElementsResolver
            
            eventsHandler = AdaptyUIEventsHandler(logId: logId)
            logic = AdaptyUIBuilderAppLogic(
                logId: logId,
                products: products,
                events: eventsHandler
            )
            presentationViewModel = AdaptyUIPresentationViewModel(logId: logId, logic: logic)
            tagResolverViewModel = AdaptyUITagResolverViewModel(tagResolver: tagResolver)
            customElementsViewModel = AdaptyUICustomElementsViewModel(customElementsResolver: customElementsResolver)
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
                flowViewModel: flowViewModel,
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

        /// Sends a message from the app to the script of this flow.
        ///
        /// The script receives it in `handleSDKEvent` as an SDK event named
        /// `app_msg` and decides what to do with it — set a variable, fire flow
        /// events, anything else. Unlike a message from a custom element, this
        /// one carries neither a screen instance nor an element identity, so a
        /// script that needs to reach a specific screen has to name it itself;
        /// `SDK.sendEvents` without an `instanceId` reaches every navigator.
        ///
        /// Arguments cross into JavaScript as JSON: a string and a boolean stay
        /// themselves, every number becomes a JS number, `nil` and `NSNull`
        /// become `null`, arrays and nested dictionaries are carried through,
        /// and a value of any other type becomes `null`.
        ///
        /// Delivery does not depend on the flow being on screen: the script
        /// runs from the moment this configuration is created.
        public func sendAppMessage(_ arguments: [String: any Sendable]) {
            stateViewModel.sendAppMessage(arguments)
        }

        /// Resets the transient runtime state so this configuration can be
        /// presented again as a fresh flow. Intended for cross-platform SDKs
        /// that reuse a cached `FlowConfiguration`; otherwise prefer creating
        /// a new one.
        public func prepareForReuse() {
            Log.ui.verbose("#\(logId)# prepareForReuse")
            screensViewModel.prepareForReuse()
            productsViewModel.prepareForReuse()
            assetsViewModel.prepareForReuse()
            presentationViewModel.prepareForReuse()
            timerViewModel.prepareForReuse()
            stateViewModel.prepareForReuse()
            flowViewModel.prepareForReuse()
        }
    }
}

#endif
