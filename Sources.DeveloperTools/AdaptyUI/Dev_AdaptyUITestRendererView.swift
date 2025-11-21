//
//  Dev_AdaptyUIRendererView.swift
//  AdaptyDeveloperTools
//
//  Created by Aleksei Valiano on 24.09.2025.
//

#if canImport(UIKit)
import AdaptyUI
import AdaptyUIBuilder
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
public extension AdaptyUI {
    @MainActor
    final class Dev_GalleryPreviewConfiguration {
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

        private let logic = Dev_AdaptyUILogic()

        fileprivate let logId: String
        fileprivate let observerModeResolver: AdaptyObserverModeResolver?
        fileprivate let tagResolver: AdaptyUITagResolver?
        fileprivate let timerResolver: AdaptyTimerResolver?
        fileprivate let assetsResolver: AdaptyUIAssetsResolver?

        package init(
            logId: String,
            viewConfiguration: AdaptyUIConfiguration,
            observerModeResolver: AdaptyObserverModeResolver?,
            tagResolver: AdaptyUITagResolver?,
            timerResolver: AdaptyTimerResolver?,
            assetsResolver: AdaptyUIAssetsResolver?
        ) {
            self.logId = logId
            self.observerModeResolver = observerModeResolver
            self.tagResolver = tagResolver
            self.timerResolver = timerResolver
            self.assetsResolver = assetsResolver

            eventsHandler = AdaptyEventsHandler(logId: logId)
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
                products: nil
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
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
public struct Dev_AdaptyUIRendererView: View {
    let viewConfiguration: AdaptyUIConfiguration
    let galleryConfiguration: AdaptyUI.Dev_GalleryPreviewConfiguration

    public init(
        viewConfiguration: Dev_AdaptyUIConfiguration,
        assetsResolver: AdaptyUIAssetsResolver?
    ) {
        self.viewConfiguration = viewConfiguration.wrapped
        galleryConfiguration = .init(
            logId: "test",
            viewConfiguration: viewConfiguration.wrapped,
            observerModeResolver: nil,
            tagResolver: ["TEST_TAG": "Adapty"],
            timerResolver: nil,
            assetsResolver: assetsResolver
        )
    }

    public var body: some View {
        AdaptyUIElementView(viewConfiguration.screen.content)
            .environmentObject(galleryConfiguration.eventsHandler)
            .environmentObject(galleryConfiguration.paywallViewModel)
            .environmentObject(galleryConfiguration.actionsViewModel)
            .environmentObject(galleryConfiguration.sectionsViewModel)
            .environmentObject(galleryConfiguration.productsViewModel)
            .environmentObject(galleryConfiguration.tagResolverViewModel)
            .environmentObject(galleryConfiguration.timerViewModel)
            .environmentObject(galleryConfiguration.screensViewModel)
            .environmentObject(galleryConfiguration.assetsViewModel)
            .environment(\.layoutDirection, viewConfiguration.isRightToLeft ? .rightToLeft : .leftToRight)
    }
}

#endif
