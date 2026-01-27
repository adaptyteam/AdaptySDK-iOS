//
//  AdaptyUIButtonView.swift
//
//
//  Created by Aleksey Goncharov on 2.4.24..
//

#if canImport(UIKit)

import SwiftUI

struct AdaptyUIButtonView: View {
    @Environment(\.adaptyScreenId)
    private var screenId: String
    @Environment(\.adaptyScreenInstance)
    private var screen: VC.ScreenInstance

    private var button: VC.Button

    @EnvironmentObject var stateViewModel: AdaptyUIStateViewModel
    @EnvironmentObject var paywallViewModel: AdaptyUIPaywallViewModel
    @EnvironmentObject var productsViewModel: AdaptyUIProductsViewModel
    @EnvironmentObject var sectionsViewModel: AdaptyUISectionsViewModel
    @EnvironmentObject var screensViewModel: AdaptyUIScreensViewModel

    init(_ button: VC.Button) {
        self.button = button
    }

    private var currentStateView: VC.Element {
        guard let selectedCondition = button.selectedCondition else {
            return button.normalState
        }

        switch selectedCondition {
        case let .selectedSection(sectionId, sectionIndex):
            if sectionIndex == sectionsViewModel.selectedIndex(for: sectionId) {
                return button.selectedState ?? button.normalState
            } else {
                return button.normalState
            }
        case let .selectedProduct(productId, productsGroupId):
            if productId == productsViewModel.selectedProductId(by: productsGroupId) {
                return button.selectedState ?? button.normalState
            } else {
                return button.normalState
            }
        }
    }

    public var body: some View {
        Button {
            stateViewModel.execute(
                actions: button.actions,
                screen: screen
            )
        } label: {
            AdaptyUIElementView(currentStateView)
        }
        .buttonStyle(.plain)
    }
}

#endif
