//
//  File.swift
//
//
//  Created by Aleksey Goncharov on 20.05.2024.
//

#if canImport(UIKit)

    import Adapty
    import AdaptyUI
    import Foundation
    import SwiftUI

    package extension AdaptyUI.LocalizedViewConfiguration {
        static func createTest(
            templateId: String = "basic",
            locale: String = "en",
            isRightToLeft: Bool = false,
            images: [String] = [],
            colors: [String: AdaptyUI.ColorFilling] = [:],
            strings: [String: [String]] = [:],
            content: String
        ) throws -> Self {
            try create(
                templateId: templateId,
                locale: locale,
                isRightToLeft: isRightToLeft,
                images: images,
                colors: colors,
                strings: strings,
                content: content
            )
        }
    }

    @available(iOS 15.0, *)
    public enum AdaptyUIPreviewRenderingMode: String, CaseIterable {
        case template
        case element
    }

    @available(iOS 15.0, *)
    public struct AdaptyUITestRendererView: View {
        var eventsHandler: AdaptyEventsHandler
        var viewConfiguration: AdaptyUI.LocalizedViewConfiguration
        var renderingMode: AdaptyUIPreviewRenderingMode

        public init(
            viewConfiguration: AdaptyUI.LocalizedViewConfiguration,
            renderingMode: AdaptyUIPreviewRenderingMode
        ) {
            self.viewConfiguration = viewConfiguration
            self.renderingMode = renderingMode
            self.eventsHandler = AdaptyEventsHandler()
        }

        @ViewBuilder
        private func drawAsElement(screen: AdaptyUI.Screen) -> some View {
            AdaptyUIElementView(screen.content)
        }

        @ViewBuilder
        private func templateOrElement() -> some View {
            let screen = viewConfiguration.screen

            switch renderingMode {
            case .template:
                if let template = AdaptyUI.Template(rawValue: viewConfiguration.templateId) {
                    AdaptyUITemplateResolverView(
                        template: template,
                        screen: screen
                    )

                } else {
                    AdaptyUIRenderingErrorView(text: "Wrong templateId: \(viewConfiguration.templateId)", forcePresent: true)
                }
            case .element:
                AdaptyUIElementView(screen.content)
            }
        }

        public var body: some View {
            let actionsVM = AdaptyUIActionsViewModel(eventsHandler: eventsHandler)
            let sectionsVM = AdaptySectionsViewModel(logId: "AdaptyUITesting")
            let productsVM = AdaptyProductsViewModel(
                eventsHandler: eventsHandler,
                paywall: AdaptyMockPaywall(),
                products: nil,
                viewConfiguration: viewConfiguration
            )
            let tagResolverVM = AdaptyTagResolverViewModel(tagResolver: ["TEST_TAG": "Adapty"])
            let screensVM = AdaptyScreensViewModel(
                eventsHandler: eventsHandler,
                viewConfiguration: viewConfiguration
            )
            let timerVM = AdaptyTimerViewModel(
                productsViewModel: productsVM,
                actionsViewModel: actionsVM,
                sectionsViewModel: sectionsVM,
                screensViewModel: screensVM
            )

            templateOrElement()
                .environmentObject(actionsVM)
                .environmentObject(sectionsVM)
                .environmentObject(productsVM)
                .environmentObject(tagResolverVM)
                .environmentObject(timerVM)
                .environmentObject(screensVM)
                .environment(\.layoutDirection, viewConfiguration.isRightToLeft ? .rightToLeft : .leftToRight)
        }
    }

#endif
