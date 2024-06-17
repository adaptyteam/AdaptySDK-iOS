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
    private var button: AdaptyUI.Button

    @EnvironmentObject var productsViewModel: AdaptyProductsViewModel
    @EnvironmentObject var actionsViewModel: AdaptyUIActionsViewModel
    @EnvironmentObject var sectionsViewModel: AdaptySectionsViewModel

    init(_ button: AdaptyUI.Button) {
        self.button = button
    }

    private var currentStateView: AdaptyUI.Element {
        switch button.action {
        case let .selectProductId(productId):
            if productId == productsViewModel.selectedProductId {
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

    private func actionOccured() {
        let action = button.action

        switch action {
        case let .selectProductId(id):
            productsViewModel.selectProduct(id: id)
        case .purchaseSelectedProduct:
            productsViewModel.purchaseSelectedProduct()
        case let .purchaseProductId(productId):
            productsViewModel.purchaseProduct(id: productId)
        case .restore:
            productsViewModel.restorePurchases()
        case let .switchSection(sectionId, index):
            sectionsViewModel.updateSelection(for: sectionId, index: index)
        case let .openScreen(id):
            // TODO: implement
            break
        case .closeScreen:
            // TODO: implement
            break
        case .close:
            actionsViewModel.closeActionOccured()
        case let .openUrl(url):
            actionsViewModel.openUrlActionOccured(url: url)
        case let .custom(id):
            actionsViewModel.customActionOccured(id: id)
        }
    }

    public var body: some View {
        Button {
            actionOccured()
        } label: {
            AdaptyUIElementView(currentStateView)
        }
    }
}

#endif
