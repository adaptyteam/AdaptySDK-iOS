//
//  CategoriesListView.swift
//  AdaptyRecipes-SwiftUI
//
//  Created by Aleksey Goncharov on 28.06.2024.
//

import Adapty
import AdaptyUI
import SwiftUI
import WebKit

// ⚠️ Implement ObserverModeResolver to work in ObserverMode
// class ObserverModeResolver: AdaptyObserverModeResolver {
//    func observerMode(
//        didInitiatePurchase product: AdaptyPaywallProduct,
//        onStartPurchase: @escaping () -> Void,
//        onFinishPurchase: @escaping () -> Void
//    ) {
//        // handle the purchase
//    }
// }

struct CategoriesListView: View {
    @EnvironmentObject private var viewModel: MainViewModel

    @State private var presentPaywallModally: Bool = false
    @State private var flowConfig: AdaptyUI.FlowConfiguration?
    @State private var alertError: IdentifiableErrorWrapper?
    @State private var alertPaywallError: IdentifiableErrorWrapper?

    var body: some View {
        List {
            Section(header: Text("Basic Recipes")) {
                ForEach(CategoryModel.allCases.filter { !$0.isPremium }) { category in
                    NavigationLink(destination: self.recipeDetails(for: category)) {
                        self.recipeRow(for: category)
                    }
                }
            }

            Section(header: Text("Premium Recipes")) {
                ForEach(CategoryModel.allCases.filter { $0.isPremium }) { category in
                    if self.viewModel.isPremiumUser {
                        NavigationLink(destination: self.recipeDetails(for: category)) {
                            self.recipeRow(for: category)
                        }
                    } else {
                        switch category.presentationStyle {
                        case .modal:
                            Button {
                                self.presentPaywallModally = true
                            } label: {
                                self.recipeRow(for: category)
                            }
                        case .navigation:
                            FlowNavigationLink(flowConfiguration: flowConfig) {
                                self.recipeRow(for: category)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Adapty Recipes")
        .flow(
            isPresented: $presentPaywallModally,
            flowConfiguration: flowConfig,
            // ⚠️ Pass AdaptyObserverModeResolver object to work in ObserverMode
            // observerModeResolver: ObserverModeResolver(),
            didFailPurchase: { _, error in
                alertPaywallError = .init(title: "didFailPurchase error!", error: error)
            },
            didFinishRestore: { _ in
                // handle event
            },
            didFailRestore: { error in
                alertPaywallError = .init(title: "didFailRestore error!", error: error)
            },
            didFailRendering: { error in
                presentPaywallModally = false
                alertPaywallError = .init(title: "didFailRendering error!", error: error)
            },
            showAlertItem: $alertPaywallError,
            showAlertBuilder: { errorItem in
                Alert(
                    title: Text(errorItem.title),
                    message: Text("\(errorItem.error.localizedDescription)"),
                    dismissButton: .cancel()
                )
            }
        )
        .task {
            guard flowConfig == nil else { return }
            
            do {
                let flow = try await Adapty.getFlow(placementId: AppConstants.placementId)
                flowConfig = try await AdaptyUI.getFlowConfiguration(forFlow: flow)
            } catch {
                Logger.log(.error, "getFlowAndConfig: \(error)")
                alertError = .init(title: "getFlowAndConfig error!", error: error)
            }
        }
        .alert(item: $alertError) { errorWrapper in
            Alert(
                title: Text(errorWrapper.title),
                message: Text("\(errorWrapper.error.localizedDescription)"),
                dismissButton: .cancel()
            )
        }
    }

    @ViewBuilder
    private func recipeRow(for category: CategoryModel) -> some View {
        HStack {
            Text(category.emoji)
                .font(.largeTitle)
            Text(category.title)
                .font(.headline)
                .padding(.leading, 5)

            Spacer()

            Text("(\(category.presentationStyle.rawValue))")
                .font(.caption)
        }
        .foregroundColor(.primary)
    }

    @ViewBuilder
    private func recipeDetails(for category: CategoryModel) -> some View {
        List {
            Text("Recipe 1 for \(category.title)")
            Text("Recipe 2 for \(category.title)")
        }
        .navigationTitle(category.title)
    }
}

#Preview {
    NavigationView {
        CategoriesListView()
            .environmentObject(MainViewModel())
    }
}
