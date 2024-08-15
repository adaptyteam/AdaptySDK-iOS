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

#if DEBUG
public extension AdaptyUI.LocalizedViewConfiguration {
    static func createTest(
        templateId: String = "basic",
        locale: String = "en",
        isRightToLeft: Bool = false,
        images: [String] = [],
        content: String
    ) throws -> Self {
        try create(
            templateId: templateId,
            locale: locale,
            isRightToLeft: isRightToLeft,
            images: images,
            colors: [
                "$green_figma": AdaptyUI.ColorFilling.createColor(value: .create(data: 0x3EBD78FF)),
                "$green_figma_cc": AdaptyUI.ColorFilling.createColor(value: .create(data: 0x3EBD78CC)),
                "$black20": AdaptyUI.ColorFilling.createColor(value: .create(data: 0x01010138)),
                "$black80": AdaptyUI.ColorFilling.createColor(value: .create(data: 0x010101CC)),
                "$black": AdaptyUI.ColorFilling.createColor(value: .create(data: 0x000000FF)),
                "$white": AdaptyUI.ColorFilling.createColor(value: .create(data: 0xFFFFFFFF)),
                "$red": AdaptyUI.ColorFilling.createColor(value: .create(data: 0xFF0000FF)),
                "$red_2": AdaptyUI.ColorFilling.createColor(value: .create(data: 0xF3227AFF)),
                "$red_2_transparent": AdaptyUI.ColorFilling.createColor(value: .create(data: 0xF3227A44)),
                "$green": AdaptyUI.ColorFilling.createColor(value: .create(data: 0x00FF00FF)),
                "$blue": AdaptyUI.ColorFilling.createColor(value: .create(data: 0x0000FFFF)),
                "$light": .createColor(value: .create(data: 0xF4D13BFF)),
                "$red_to_transparent_top_to_bottom": .createGradient(value: .create(
                    kind: .linear,
                    start: .create(x: 0.5, y: 0.0),
                    end: .create(x: 0.5, y: 1.0),
                    items: [
                        .create(color: .create(data: 0xFF000099), p: 0.0),
                        .create(color: .create(data: 0xFF000000), p: 1.0),
                    ]
                )),
                "$blue_to_transparent_top_to_bottom": .createGradient(value: .create(
                    kind: .linear,
                    start: .create(x: 0.5, y: 0.0),
                    end: .create(x: 0.5, y: 1.0),
                    items: [
                        .create(color: .create(data: 0x0000FF99), p: 0.0),
                        .create(color: .create(data: 0x0000FF00), p: 1.0),
                    ]
                )),
                "$green_to_transparent_top_to_bottom": .createGradient(value: .create(
                    kind: .linear,
                    start: .create(x: 0.5, y: 0.0),
                    end: .create(x: 0.5, y: 1.0),
                    items: [
                        .create(color: .create(data: 0x00FF0099), p: 0.0),
                        .create(color: .create(data: 0x00FF0000), p: 1.0),
                    ]
                )),
                "$yellow_to_purple_top_to_bottom": .createGradient(value: .create(
                    kind: .linear,
                    start: .create(x: 0.5, y: 0.0),
                    end: .create(x: 0.5, y: 1.0),
                    items: [
                        .create(color: .create(data: 0xF9B61AFF), p: 0.0),
                        .create(color: .create(data: 0x8A4DECFF), p: 1.0),
                    ]
                )),
                "$pink_to_red_top_to_bottom": .createGradient(value: .create(
                    kind: .linear,
                    start: .create(x: 0.5, y: 0.0),
                    end: .create(x: 0.5, y: 1.0),
                    items: [
                        .create(color: .create(data: 0xB577BFFF), p: 0.0),
                        .create(color: .create(data: 0xF3227AFF), p: 1.0),
                    ]
                )),
            ],
            strings: [
                "$short": ["Article."],
                "$medium": ["Article nor prepare chicken you him now."],
                "$long": ["Article nor prepare chicken you him now. Shy merits say advice ten before lovers innate add. "],
                "$timer_basic": ["#TIMER_Total_Days_1", "d ", "#TIMER_hh", ":", "#TIMER_mm", ":", "#TIMER_ss"],
                "$countdown": ["#TIMER_Total_Seconds_1"],
                "$card_title": ["Before this app I wasn't able to do anything by myself. Now I am, wow! Highly recommend!"],
                "$card_subtitle": ["App Store review"],
                "$footer_restore": ["Restore Purchases"],
                "$footer_terms": ["Terms & Conditions"],
                "$footer_privacy": ["Privacy Policy"],
                "$footer_support": ["Support"],

                "$product_title_1": ["Weekly"],
                "$product_title_2": ["Offer Text"],
                "$product_title_3": ["$99.99"],
                "$product_title_4": ["$9.99 / week"],

                "$string_section_button_a": ["Section A"],
                "$section_a_title": ["Selected Section A Content"],
                "$string_section_button_b": ["Section B"],
                "$section_b_title": ["Selected Section B Content"],
            ],
            content: content
        )
    }
}
#endif

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

    public var body: some View {
        let actionsVM = AdaptyUIActionsViewModel(eventsHandler: eventsHandler)
        let sectionsVM = AdaptySectionsViewModel(logId: "AdaptyUITesting")
        let paywallVM = AdaptyPaywallViewModel(eventsHandler: eventsHandler,
                                               paywall: AdaptyMockPaywall(),
                                               viewConfiguration: viewConfiguration)
        let productsVM = AdaptyProductsViewModel(eventsHandler: eventsHandler,
                                                 paywallViewModel: paywallVM,
                                                 products: nil,
                                                 introductoryOffersEligibilities: nil)
        let tagResolverVM = AdaptyTagResolverViewModel(tagResolver: ["TEST_TAG": "Adapty"])
        let screensVM = AdaptyScreensViewModel(
            eventsHandler: eventsHandler,
            viewConfiguration: viewConfiguration
        )
        let timerVM = AdaptyTimerViewModel(
            timerResolver: AdaptyUIDefaultTimerResolver(),
            paywallViewModel: paywallVM,
            productsViewModel: productsVM,
            actionsViewModel: actionsVM,
            sectionsViewModel: sectionsVM,
            screensViewModel: screensVM
        )
        
        let videoVM = AdaptyVideoViewModel(eventsHandler: eventsHandler)

        AdaptyUIElementView(viewConfiguration.screen.content)
            .environmentObject(paywallVM)
            .environmentObject(actionsVM)
            .environmentObject(sectionsVM)
            .environmentObject(productsVM)
            .environmentObject(tagResolverVM)
            .environmentObject(timerVM)
            .environmentObject(screensVM)
            .environmentObject(videoVM)
            .environment(\.layoutDirection, viewConfiguration.isRightToLeft ? .rightToLeft : .leftToRight)
    }
}

@available(iOS 15.0, *)
public extension View {
    func withScreenSizeTestingWrapper(_ value: CGSize) -> some View {
        withScreenSize(value)
    }
}

#endif
