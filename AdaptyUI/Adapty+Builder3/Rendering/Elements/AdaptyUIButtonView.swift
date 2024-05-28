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

    init(_ button: AdaptyUI.Button) {
        self.button = button
    }

    private var currentStateView: AdaptyUI.Element? {
        switch button.action {
        case .selectProductId(let productId):
            if productId == productsViewModel.selectedProductId {
                return button.selectedState ?? button.normalState
            } else {
                return button.normalState
            }
        case .switchSection(let sectionId, let selectedIndexId):
            // TODO: choose selected if needed
            return button.normalState
        default:
            return button.normalState
        }
    }
    
    private func actionOccured() {
        guard let action = button.action else { return }
        
        switch action {
        case .selectProductId(let id):
            productsViewModel.selectProduct(id: id)
        case .switchSection(let id, let index):
            // TODO: implement
            break
        case .openScreen(let id):
            // TODO: implement
            break
        case .closeScreen:
            // TODO: implement
            break
        default:
            actionsViewModel.actionOccured(action)
        }
    }

    public var body: some View {
        Button {
            actionOccured()
        } label: {
            if let currentStateView {
                AdaptyUIElementView(currentStateView)
            } else {
                EmptyView()
            }
        }
    }
}

#endif
