//
//  AdaptyUIToggleView.swift
//
//
//  Created by Aleksey Goncharov on 30.05.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct AdaptyUIToggleView: View {
    @Environment(\.adaptyScreenId)
    private var screenId: String

    @EnvironmentObject var paywallViewModel: AdaptyPaywallViewModel
    @EnvironmentObject var productsViewModel: AdaptyProductsViewModel
    @EnvironmentObject var actionsViewModel: AdaptyUIActionsViewModel
    @EnvironmentObject var sectionsViewModel: AdaptySectionsViewModel
    @EnvironmentObject var screensViewModel: AdaptyScreensViewModel

    private var toggle: AdaptyUICore.Toggle

    init(_ toggle: AdaptyUICore.Toggle) {
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
        .tint(toggle.color?.swiftuiColor)
    }
}

#if DEBUG

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
#Preview {
    AdaptyUIToggleView(.create(sectionId: "toggle_preview"))
        .environmentObject(AdaptySectionsViewModel(logId: "Preview"))
}

#endif

#endif
