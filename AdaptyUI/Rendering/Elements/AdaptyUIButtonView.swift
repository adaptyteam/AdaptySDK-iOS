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

    @EnvironmentObject var productsViewModel: AdaptyProductsViewModel
    @EnvironmentObject var actionsViewModel: AdaptyUIActionsViewModel
    @EnvironmentObject var sectionsViewModel: AdaptySectionsViewModel
    @EnvironmentObject var screensViewModel: AdaptyScreensViewModel

    init(_ button: AdaptyUI.Button) {
        self.button = button
    }

    private var currentStateView: AdaptyUI.Element {
        switch button.action {
        case let .selectProductId(productId, groupId):
            if let selectedProductId = productsViewModel.selectedProductId(by: groupId), productId == selectedProductId {
                button.selectedState ?? button.normalState
            } else {
                button.normalState
            }
        case let .switchSection(sectionId, index):
            if index == sectionsViewModel.selectedIndex(for: sectionId) {
                button.selectedState ?? button.normalState
            } else {
                button.normalState
            }
        default:
            button.normalState
        }
    }

    public var body: some View {
        Button {
            button.action.fire(
                screenId: screenId,
                productsViewModel: productsViewModel,
                actionsViewModel: actionsViewModel,
                sectionsViewModel: sectionsViewModel,
                screensViewModel: screensViewModel
            )
        } label: {
            AdaptyUIElementView(currentStateView)
        }
    }
}

@available(iOS 15.0, *)
extension AdaptyUI.ButtonAction {
    func fire(
        screenId: String,
        productsViewModel: AdaptyProductsViewModel,
        actionsViewModel: AdaptyUIActionsViewModel,
        sectionsViewModel: AdaptySectionsViewModel,
        screensViewModel: AdaptyScreensViewModel
    ) {
        switch self {
        case let .selectProductId(id, groupId):
            productsViewModel.selectProduct(id: id, forGroupId: groupId)
        case let .unselectProduct(groupId): // TODO:
            break
        case let .purchaseSelectedProduct(groupId):
            productsViewModel.purchaseSelectedProduct(fromGgoupId: groupId)
        case let .purchaseProductId(productId):
            productsViewModel.purchaseProduct(id: productId)
        case .restore:
            productsViewModel.restorePurchases()
        case let .switchSection(sectionId, index):
            sectionsViewModel.updateSelection(for: sectionId, index: index)
        case let .openScreen(id):
//            withAnimation {
            screensViewModel.presentScreen(id: id)
//            }
        case .closeScreen:
//            withAnimation {
            screensViewModel.dismissScreen(id: screenId)
//            }
        case .close:
            actionsViewModel.closeActionOccured()
        case let .openUrl(url):
            actionsViewModel.openUrlActionOccured(url: url)
        case let .custom(id):
            actionsViewModel.customActionOccured(id: id)
        }
    }
}

#endif
