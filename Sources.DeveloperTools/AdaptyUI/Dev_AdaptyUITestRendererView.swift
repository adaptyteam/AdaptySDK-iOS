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

public extension AdaptyUI {
    @MainActor
    final class Dev_GalleryPreviewConfiguration {
        package let eventsHandler: AdaptyEventsHandler

        package let presentationViewModel: AdaptyUIPresentationViewModel
        package let stateViewModel: AdaptyUIStateViewModel
        package let paywallViewModel: AdaptyUIPaywallViewModel
        package let productsViewModel: AdaptyUIProductsViewModel
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
            let actionHandler = AdaptyUIStateActionHandler(
                productsViewModel: productsViewModel,
                screensViewModel: screensViewModel,
                logic: logic
            )
            stateViewModel = AdaptyUIStateViewModel(
                logId: logId,
                logic: logic,
                actionHandler: actionHandler,
                viewConfiguration: viewConfiguration,
                isInspectable: false
            )
            timerViewModel = AdaptyUITimerViewModel(
                logId: logId,
                timerResolver: timerResolver ?? AdaptyUIDefaultTimerResolver(),
                stateViewModel: stateViewModel,
                paywallViewModel: paywallViewModel,
                productsViewModel: productsViewModel,
                sectionsViewModel: sectionsViewModel,
                screensViewModel: screensViewModel
            )
            assetsViewModel = AdaptyUIAssetsViewModel(
                assetsResolver: assetsResolver ?? AdaptyUIDefaultAssetsResolver()
            )
        }
    }
}

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
        AdaptyUIElementView(viewConfiguration.screens["main"]!.content)
            .environmentObjects(
                stateViewModel: galleryConfiguration.stateViewModel,
                paywallViewModel: galleryConfiguration.paywallViewModel,
                productsViewModel: galleryConfiguration.productsViewModel,
                sectionsViewModel: galleryConfiguration.sectionsViewModel,
                tagResolverViewModel: galleryConfiguration.tagResolverViewModel,
                timerViewModel: galleryConfiguration.timerViewModel,
                screensViewModel: galleryConfiguration.screensViewModel,
                assetsViewModel: galleryConfiguration.assetsViewModel
            )
            .environment(\.layoutDirection, viewConfiguration.isRightToLeft ? .rightToLeft : .leftToRight)
    }
}



#endif
