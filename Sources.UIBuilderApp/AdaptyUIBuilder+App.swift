//
//  AdaptyUIBuilder+App.swift
//  Adapty
//
//  Created by Alexey Goncharov on 9/23/25.
//

import AdaptyLogger
import AdaptyUIBuider
import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
public extension AdaptyUIBuilder {
    static func getPaywallConfiguration(
        forSchema schema: AdaptyUISchema,
        localeId: LocaleId?,
        products: [ProductResolver],
        tagResolver: AdaptyTagResolver?,
        timerResolver: AdaptyTimerResolver?,
        assetsResolver: AdaptyAssetsResolver?
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
public typealias AdaptyTimerResolver = AdaptyUIBuider.AdaptyTimerResolver

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
public typealias AdaptyTagResolver = AdaptyUIBuider.AdaptyTagResolver

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
public typealias AdaptyAssetsResolver = AdaptyUIBuider.AdaptyAssetsResolver

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
public typealias AdaptyCustomAsset = AdaptyUIBuider.AdaptyCustomAsset

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
public extension AdaptyUIBuilder {
    @MainActor
    final class PaywallConfiguration {
        let eventsHandler: AdaptyEventsHandler

        let presentationViewModel: AdaptyPresentationViewModel
        let paywallViewModel: AdaptyPaywallViewModel
        let productsViewModel: AdaptyProductsViewModel
        let actionsViewModel: AdaptyUIActionsViewModel
        let sectionsViewModel: AdaptySectionsViewModel
        let tagResolverViewModel: AdaptyTagResolverViewModel
        let timerViewModel: AdaptyTimerViewModel
        let screensViewModel: AdaptyScreensViewModel
        let assetsViewModel: AdaptyAssetsViewModel

        let logic: AdaptyUIBuilderAppLogic

        fileprivate let logId: String
        fileprivate let tagResolver: AdaptyTagResolver?
        fileprivate let timerResolver: AdaptyTimerResolver?
        fileprivate let assetsResolver: AdaptyAssetsResolver?

        init(
            logId: String,
            viewConfiguration: AdaptyUIConfiguration,
            products: [ProductResolver],
            tagResolver: AdaptyTagResolver?,
            timerResolver: AdaptyTimerResolver?,
            assetsResolver: AdaptyAssetsResolver?
        ) {
            self.logId = logId
            self.tagResolver = tagResolver
            self.timerResolver = timerResolver
            self.assetsResolver = assetsResolver

            eventsHandler = AdaptyEventsHandler(logId: logId)
            logic = AdaptyUIBuilderAppLogic(logId: logId, products: products, events: eventsHandler)

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
                products: products,
                observerModeResolver: nil
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
