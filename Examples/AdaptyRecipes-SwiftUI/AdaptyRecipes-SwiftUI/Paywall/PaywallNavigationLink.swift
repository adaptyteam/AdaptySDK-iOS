//
//  PaywallNavigationLink.swift
//  AdaptyRecipes-SwiftUI
//
//  Created by Alexey Goncharov on 1/14/25.
//

import Adapty
import AdaptyUI
import SwiftUI

struct PaywallNavigationLink<Label>: View where Label: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    private var placementId: String
    private var label: () -> Label

    init(placementId: String, label: @escaping () -> Label) {
        self.placementId = placementId
        self.label = label
    }

    @State private var paywallConfig: AdaptyUI.PaywallConfiguration?

    var body: some View {
        NavigationLink {
            if let paywallConfig {
                AdaptyPaywallView(
                    paywallConfiguration: paywallConfig,
                    didFailPurchase: { _, error in
//                        alertPaywallError = .init(title: "didFailPurchase error!", error: error)
                    },
                    didFinishRestore: { _ in
                        // handle event
                    },
                    didFailRestore: { error in
//                        alertPaywallError = .init(title: "didFailRestore error!", error: error)
                    },
                    didFailRendering: { error in
//                        isPresented.wrappedValue = false
//                        alertPaywallError = .init(title: "didFailRendering error!", error: error)
                    }
                )
            } else {
                EmptyView()
            }
        } label: {
            label()
        }
        .disabled(paywallConfig == nil)
        .task {
            do {
                let paywall = try await Adapty.getPaywall(placementId: placementId)
                paywallConfig = try await AdaptyUI.getPaywallConfiguration(forPaywall: paywall)
            } catch {
                Logger.log(.error, "getPaywallAndConfig: \(error)")
            }
        }
    }
}
