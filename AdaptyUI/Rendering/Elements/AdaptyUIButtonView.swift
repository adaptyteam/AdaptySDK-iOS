//
//  AdaptyUIButtonView.swift
//
//
//  Created by Aleksey Goncharov on 2.4.24..
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct AdaptyUIButtonView: View {
    @Environment(\.adaptyScreenId)
    private var screenId: String

    private var button: VC.Button

    @EnvironmentObject var paywallViewModel: AdaptyPaywallViewModel
    @EnvironmentObject var productsViewModel: AdaptyProductsViewModel
    @EnvironmentObject var actionsViewModel: AdaptyUIActionsViewModel
    @EnvironmentObject var sectionsViewModel: AdaptySectionsViewModel
    @EnvironmentObject var screensViewModel: AdaptyScreensViewModel

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
            for action in button.actions {
                action.fire(
                    screenId: screenId,
                    paywallViewModel: paywallViewModel,
                    productsViewModel: productsViewModel,
                    actionsViewModel: actionsViewModel,
                    sectionsViewModel: sectionsViewModel,
                    screensViewModel: screensViewModel
                )
            }
        } label: {
            AdaptyUIElementView(currentStateView)
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
extension [VC.ActionAction] {
    func fire(
        screenId: String,
        paywallViewModel: AdaptyPaywallViewModel,
        productsViewModel: AdaptyProductsViewModel,
        actionsViewModel: AdaptyUIActionsViewModel,
        sectionsViewModel: AdaptySectionsViewModel,
        screensViewModel: AdaptyScreensViewModel
    ) {
        forEach {
            $0.fire(
                screenId: screenId,
                paywallViewModel: paywallViewModel,
                productsViewModel: productsViewModel,
                actionsViewModel: actionsViewModel,
                sectionsViewModel: sectionsViewModel,
                screensViewModel: screensViewModel
            )
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
extension VC.ActionAction {
    func fire(
        screenId: String,
        paywallViewModel: AdaptyPaywallViewModel,
        productsViewModel: AdaptyProductsViewModel,
        actionsViewModel: AdaptyUIActionsViewModel,
        sectionsViewModel: AdaptySectionsViewModel,
        screensViewModel: AdaptyScreensViewModel
    ) {
        switch self {
        case let .selectProduct(id, groupId):
            withAnimation(.linear(duration: 0.0)) {
                productsViewModel.selectProduct(id: id, forGroupId: groupId)
            }
        case let .unselectProduct(groupId):
            productsViewModel.unselectProduct(forGroupId: groupId)
        case let .purchaseSelectedProduct(groupId, provider):
            productsViewModel.purchaseSelectedProduct(fromGroupId: groupId, provider: provider)
        case let .purchaseProduct(productId, provider):
            productsViewModel.purchaseProduct(id: productId, provider: provider)
        case .openWebPaywall:
            break
        case .restore:
            productsViewModel.restorePurchases()
        case let .switchSection(sectionId, index):
            withAnimation(.linear(duration: 0.0)) {
                sectionsViewModel.updateSelection(for: sectionId, index: index)
            }
        case let .openScreen(id):
            withAnimation(.linear(duration: 0.3)) {
                screensViewModel.presentScreen(id: id)
            }
        case .closeScreen:
            screensViewModel.dismissScreen(id: screenId)
        case .close:
            actionsViewModel.closeActionOccurred()
        case let .openUrl(url):
            actionsViewModel.openUrlActionOccurred(url: url)
        case let .custom(id):
            switch id {
            case "$adapty_reload_data":
                paywallViewModel.reloadData()
            default:
                actionsViewModel.customActionOccurred(id: id)
            }
        }
    }
}

#endif
