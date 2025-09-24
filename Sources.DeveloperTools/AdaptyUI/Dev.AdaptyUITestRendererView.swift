//
//  AdaptyUITestRendererView.swift
//  AdaptyDeveloperTools
//
//  Created by Aleksei Valiano on 24.09.2025.
//

#if canImport(UIKit)
import AdaptyUI
import AdaptyUIBuider
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
public extension Dev {
    struct AdaptyUITestRendererView: View {
        let viewConfiguration: AdaptyUIConfiguration.Wrapped
        //    let paywallConfiguration: AdaptyUI.PaywallConfiguration

        public init(
            viewConfiguration: Dev.AdaptyUIConfiguration,
            assetsResolver: AdaptyAssetsResolver?
        ) {
            self.viewConfiguration = viewConfiguration.wrapped

            //        paywallConfiguration = AdaptyUI.PaywallConfiguration(
            //            logId: Log.stamp,
            //            paywall: AdaptyMockPaywall(),
            //            viewConfiguration: viewConfiguration,
            //            products: nil,
            //            observerModeResolver: nil,
            //            tagResolver: ["TEST_TAG": "Adapty"],
            //            timerResolver: nil,
            //            assetsResolver: assetsResolver
            //        )
        }

        public var body: some View {
            EmptyView()
            //        AdaptyUIElementView(viewConfiguration.screen.content)
            //            .environmentObject(paywallConfiguration.eventsHandler)
            //            .environmentObject(paywallConfiguration.paywallViewModel)
            //            .environmentObject(paywallConfiguration.actionsViewModel)
            //            .environmentObject(paywallConfiguration.sectionsViewModel)
            //            .environmentObject(paywallConfiguration.productsViewModel)
            //            .environmentObject(paywallConfiguration.tagResolverViewModel)
            //            .environmentObject(paywallConfiguration.timerViewModel)
            //            .environmentObject(paywallConfiguration.screensViewModel)
            //            .environmentObject(paywallConfiguration.assetsViewModel)
            //            .environment(\.layoutDirection, viewConfiguration.isRightToLeft ? .rightToLeft : .leftToRight)
        }
    }
}

#endif
