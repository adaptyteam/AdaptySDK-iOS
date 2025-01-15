//
//  PaywallViewModifier.swift
//  AdaptyRecipes-SwiftUI
//
//  Created by Aleksey Goncharov on 28.06.2024.
//

import Adapty
import AdaptyUI
import SwiftUI

struct IdentifiableErrorWrapper: Identifiable {
    let id: String = UUID().uuidString
    let title: String
    let error: Error
}

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

#if canImport(UIKit)

struct PaywallViewModifier: ViewModifier {
    private var isPresented: Binding<Bool>
    private var placementId: String

    init(isPresented: Binding<Bool>, placementId: String) {
        self.isPresented = isPresented
        self.placementId = placementId
    }

    @State private var paywallConfig: AdaptyUI.PaywallConfiguration?

    @State private var alertError: IdentifiableErrorWrapper?
    @State private var alertPaywallError: IdentifiableErrorWrapper?

    @ViewBuilder
    @MainActor
    func contentOrSheet(content: Content) -> some View {
        if let paywallConfig {
            content
                .paywall(
                    isPresented: isPresented,
                    paywallConfiguration: paywallConfig,
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
                        isPresented.wrappedValue = false
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

        } else {
            content
        }
    }

    func body(content: Content) -> some View {
        contentOrSheet(content: content)
            .task {
                do {
                    let paywall = try await Adapty.getPaywall(placementId: placementId)
                    paywallConfig = try await AdaptyUI.getPaywallConfiguration(forPaywall: paywall)
                } catch {
                    Logger.log(.error, "getPaywallAndConfig: \(error)")
                    alertError = .init(title: "getPaywallAndConfig error!", error: error)
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
}
#endif

extension View {
    func paywall(isPresented: Binding<Bool>, placementId: String) -> some View {
#if canImport(UIKit)
        modifier(
            PaywallViewModifier(
                isPresented: isPresented,
                placementId: placementId
            )
        )
#else
        self
#endif
    }
}
