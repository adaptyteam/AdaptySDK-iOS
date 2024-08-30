//
//  AdaptyUIToggleView.swift
//
//
//  Created by Aleksey Goncharov on 30.05.2024.
//

#if canImport(UIKit)

    import Adapty
    import SwiftUI

    @available(iOS 15.0, *)
    struct AdaptyUIToggleView: View {
        @Environment(\.adaptyScreenId)
        private var screenId: String

        @EnvironmentObject var paywallViewModel: AdaptyPaywallViewModel
        @EnvironmentObject var productsViewModel: AdaptyProductsViewModel
        @EnvironmentObject var actionsViewModel: AdaptyUIActionsViewModel
        @EnvironmentObject var sectionsViewModel: AdaptySectionsViewModel
        @EnvironmentObject var screensViewModel: AdaptyScreensViewModel

        private var toggle: AdaptyUI.Toggle

        init(_ toggle: AdaptyUI.Toggle) {
            self.toggle = toggle
        }

        var body: some View {
            Toggle(isOn: .init(get: {
                switch toggle.onCondition {
                case let .selectedSection(sectionId, sectionIndex):
                    sectionIndex == sectionsViewModel.selectedIndex(for: sectionId)
                default: false
                }
            }, set: { value in
                (value ? toggle.onActions : toggle.offActions)
                    .fire(
                        screenId: screenId,
                        paywallViewModel: paywallViewModel,
                        productsViewModel: productsViewModel,
                        actionsViewModel: actionsViewModel,
                        sectionsViewModel: sectionsViewModel,
                        screensViewModel: screensViewModel
                    )
            })) {
                EmptyView()
            }
            .tint(toggle.color?.NEED_TO_CHOOSE_MODE.swiftuiColor)
        }
    }

    #if DEBUG

        @available(iOS 15.0, *)
        #Preview {
            AdaptyUIToggleView(.create(sectionId: "toggle_preview"))
                .environmentObject(AdaptySectionsViewModel(logId: "Preview"))
        }

    #endif

#endif
