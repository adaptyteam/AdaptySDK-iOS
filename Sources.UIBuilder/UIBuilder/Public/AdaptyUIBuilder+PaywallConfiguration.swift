//
//  AdaptyUIBuilder+PaywallConfiguration.swift
//  AdaptyUIBuilder
//
//  Created by Alexey Goncharov on 9/23/25.
//

import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
public extension AdaptyUIBuilder {
    static func getPaywallConfiguration(
        forSchema schema: AdaptyUISchema,
        localeId: LocaleId?,
        products: [ProductResolver],
        tagResolver: AdaptyUITagResolver?,
        timerResolver: AdaptyUITimerResolver?,
        assetsResolver: AdaptyUIAssetsResolver?
    ) async throws -> PaywallConfiguration {
        let viewConfiguration = try schema.extractUIConfiguration(withLocaleId: localeId)

        return PaywallConfiguration(
            logId: Log.stamp,
            viewConfiguration: viewConfiguration,
            products: products,
            tagResolver: tagResolver,
            timerResolver: timerResolver,
            assetsResolver: assetsResolver
        )
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
public extension AdaptyUIBuilder {
    @MainActor
    final class PaywallConfiguration {
        let eventsHandler: AdaptyUIEventsHandler

        let presentationViewModel: AdaptyUIPresentationViewModel
        let paywallViewModel: AdaptyUIPaywallViewModel
        let productsViewModel: AdaptyUIProductsViewModel
        let actionsViewModel: AdaptyUIActionsViewModel
        let sectionsViewModel: AdaptyUISectionsViewModel
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
                products: products
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
