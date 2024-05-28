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
            case let .selectProductId(productId):
                if productId == productsViewModel.selectedProductId {
                    button.selectedState ?? button.normalState
                } else {
                    button.normalState
                }
            case let .switchSection(sectionId, selectedIndexId):
                // TODO: choose selected if needed
                button.normalState
            default:
                button.normalState
            }
        }

        private func actionOccured() {
            let action = button.action

            switch action {
            case let .selectProductId(id):
                productsViewModel.selectProduct(id: id)
            case let .switchSection(id, index):
                // TODO: implement
                break
            case let .openScreen(id):
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
