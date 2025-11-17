//
//  AdaptyUIToggleView.swift
//
//
//  Created by Aleksey Goncharov on 30.05.2024.
//

#if canImport(UIKit)

import SwiftUI

struct AdaptyUIToggleView: View {
    @Environment(\.adaptyScreenId)
    private var screenId: String
    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme

    @EnvironmentObject var paywallViewModel: AdaptyUIPaywallViewModel
    @EnvironmentObject var productsViewModel: AdaptyUIProductsViewModel
    @EnvironmentObject var actionsViewModel: AdaptyUIActionsViewModel
    @EnvironmentObject var sectionsViewModel: AdaptyUISectionsViewModel
    @EnvironmentObject var screensViewModel: AdaptyUIScreensViewModel
    @EnvironmentObject var assetsViewModel: AdaptyUIAssetsViewModel

    private var toggle: VC.Toggle

    init(_ toggle: VC.Toggle) {
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
        .tint(
            toggle.color?.resolve(
                with: assetsViewModel.assetsResolver,
                colorScheme: colorScheme
            )
        )
    }
}

#endif
