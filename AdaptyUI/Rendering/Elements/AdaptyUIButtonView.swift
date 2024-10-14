//
//  AdaptyUIButtonView.swift
//
//
//  Created by Aleksey Goncharov on 2.4.24..
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, *)
struct AdaptyUIButtonView: View {
    @Environment(\.adaptyScreenId)
    private var screenId: String

    private var button: AdaptyUI.Button

    @EnvironmentObject var paywallViewModel: AdaptyPaywallViewModel
    @EnvironmentObject var productsViewModel: AdaptyProductsViewModel
    @EnvironmentObject var actionsViewModel: AdaptyUIActionsViewModel
    @EnvironmentObject var sectionsViewModel: AdaptySectionsViewModel
    @EnvironmentObject var screensViewModel: AdaptyScreensViewModel

    init(_ button: AdaptyUI.Button) {
        self.button = button
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
            if let selectedCondition = button.selectedCondition, let selectedState = button.selectedState {
                switch selectedCondition {
                case let .selectedSection(sectionId, sectionIndex):
                    if sectionIndex == sectionsViewModel.selectedIndex(for: sectionId) {
                        AdaptyUIElementView(selectedState)
                    } else {
                        AdaptyUIElementView(button.normalState)
                    }
                case let .selectedProduct(productId, productsGroupId):
                    if productId == productsViewModel.selectedProductId(by: productsGroupId) {
                        AdaptyUIElementView(selectedState)
                    } else {
                        AdaptyUIElementView(button.normalState)
                    }
                }
            } else {
                AdaptyUIElementView(button.normalState)
            }
        }
    }
}

@available(iOS 15.0, *)
@MainActor
extension [AdaptyUI.ActionAction] {
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

@available(iOS 15.0, *)
@MainActor
extension AdaptyUI.ActionAction {
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
            productsViewModel.selectProduct(id: id, forGroupId: groupId)
        case let .unselectProduct(groupId):
            productsViewModel.unselectProduct(forGroupId: groupId)
        case let .purchaseSelectedProduct(groupId):
            productsViewModel.purchaseSelectedProduct(fromGroupId: groupId)
        case let .purchaseProduct(productId):
            productsViewModel.purchaseProduct(id: productId)
        case .restore:
            productsViewModel.restorePurchases()
        case let .switchSection(sectionId, index):
            sectionsViewModel.updateSelection(for: sectionId, index: index)
        case let .openScreen(id):
            screensViewModel.presentScreen(id: id)
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
